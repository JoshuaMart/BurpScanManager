# frozen_string_literal: true

# ScanJob
class ScanJob
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: false

  def perform(*args)
    options = JSON.parse(args.first)
    resp = launch_scan(options)

    unless resp&.code == 201
      notif("Error starting scan of #{options['url']}")
      return
    end
    scan_id = resp.headers['Location']

    result = { 'scan_status' => 'starting' }
    while %w[starting crawling auditing].include?(result['scan_status'])
      result = get_scan(options, scan_id)
      sleep(10)
    end

    unless result['scan_status'] == 'succeeded'
      notif("Error with scan ID #{scan_id} - result : #{result}")
      return
    end

    parse_issues(result['issue_events'])
  end

  private

  def launch_scan(options)
    url = File.join(options['burp_url'], '/scan')
    Typhoeus.post(url, body: scan_options(options))
  end

  def scan_options(options)
    {
      protocol_option: 'specified',
      scan_configurations: [
        {
          name: options['crawl'],
          type: 'NamedConfiguration'
        },
        {
          name: options['audit'],
          type: 'NamedConfiguration'
        }
      ],
      urls: [options['url']]
    }.to_json
  end

  def get_scan(options, scan_id)
    url = File.join(options['burp_url'], '/scan', scan_id)
    resp = Typhoeus.get(url)

    resp&.code == 200 ? JSON.parse(resp.body) : { 'scan_status' => 'error' }
  end

  def notif(msg)
    webhook = Setting.find_by(name: 'Slack Webhook')&.value
    Typhoeus.post(webhook, headers: { 'Content-Type' => 'application/json' }, body: { text: msg }.to_json)
  end

  def parse_issues(issues)
    issues.each do |vuln|
      issue = vuln['issue']

      vulnerability = issue['name']
      url = CGI.unescape(issue.dig('evidence', 0, 'request_response', 'url'))
      description = CGI.unescapeHTML(issue['description'])&.gsub(%r{<(?!/?(b|br)(>|\s.*>))}, '&lt;')
      payload_b64 = issue.dig('evidence', 0, 'detail', 'payload', 'bytes')
      payload = Base64.decode64(payload_b64)
      severity = issue['severity']

      Vulnerability.create(name: vulnerability, url:, description:, payload:, severity:)
    end
  end
end
