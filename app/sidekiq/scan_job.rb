# frozen_string_literal: true

# ScanJob
class ScanJob
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: false

  def perform(*args)
    options = JSON.parse(args.first)
    scan_status = ScanStatus.find_by(url: options['url'])
    scan_status.update(state: 'In Progress')

    resp = launch_scan(options)

    unless resp&.code == 201
      scan_status.update(state: 'Error')
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
      scan_status.update(state: 'Error')
      notif("Error with scan ID #{scan_id} - result : #{result}")
      return
    end

    scan_status.update(state: 'Finished')
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
    webhook = Setting.find_by(name: 'Slack WebHook')&.value
    Typhoeus.post(webhook, headers: { 'Content-Type' => 'application/json' }, body: { text: msg }.to_json)
  end

  def parse_issues(issues)
    issues.each do |vuln|
      issue = vuln['issue']
      new_vuln = build_new_vuln(issue)

      Vulnerability.create(new_vuln)
    end
  end

  def build_new_vuln(issue)
    {
      name: issue['name'],
      url: extract_url(issue),
      description: extract_description(issue),
      payload: extract_payload(issue),
      severity: issue['severity']
    }
  end

  def extract_url(issue)
    url = issue.dig('evidence', 0, 'request_response', 'url')
    if url
      CGI.unescape(url)
    else
      notif("Error when extracting URL for issue : #{issue}")
      nil
    end
  end

  def extract_description(issue)
    description = issue['description']
    if description
      CGI.unescapeHTML(description)&.gsub(%r{<(?!/?(b|br)(>|\s.*>))}, '&lt;')
    else
      'No description'
    end
  end

  def extract_payload(issue)
    b64_payload = issue.dig('evidence', 0, 'detail', 'payload', 'bytes')
    if b64_payload
      Base64.decode64(b64_payload)
    else
      '/'
    end
  end
end
