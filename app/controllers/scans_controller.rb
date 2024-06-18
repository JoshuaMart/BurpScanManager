# frozen_string_literal: true

# ScansController
class ScansController < ApplicationController
  before_action :check_settings, only: %i[new create]

  def new; end

  def create
    urls = scan_params[:urls]&.split&.map(&:strip)
    force_scan = scan_params[:force_scan] == '1'

    options = build_options(scan_params)

    urls.each do |url|
      options[:url] = url

      scan_status = ScanStatus.find_or_initialize_by(url:)
      next unless scan_url?(scan_status, force_scan)

      scan_status.state = 'Waiting'
      scan_status.save

      ScanJob.perform_async(options.to_json)
    end

    redirect_to new_scan_path, notice: 'Scans started successfully.'
  end

  private

  def scan_url?(scan_status, force_scan)
    scan_status.new_record? ||
      scan_status.state == 'Error' ||
      (force_scan && !['Waiting', 'In Progress'].include?(scan_status.state))
  end

  def build_options(scan_params)
    api_url = Setting.find_by(name: 'Burp API URL')&.value
    api_token = Setting.find_by(name: 'Burp API Token')&.value

    {
      burp_url: File.join(api_url, api_token, '/v0.1/'),
      crawl: scan_params[:crawl].presence || Setting.find_by(name: 'Burp Crawl Configuration Name')&.value,
      audit: scan_params[:audit].presence || Setting.find_by(name: 'Burp Audit Configuration Name')&.value
    }
  end

  def scan_params
    params.require(:scan).permit(:urls, :crawl, :audit, :force_scan)
  end

  def check_settings
    missing_settings = Setting.any? { |v| v[:value].empty? }

    return unless missing_settings

    redirect_to settings_path, alert: 'Please fill in all required settings before launching a scan'
  end
end
