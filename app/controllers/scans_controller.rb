# frozen_string_literal: true

# ScansController
class ScansController < ApplicationController
  before_action :check_settings, only: %i[new create]

  def new; end

  def create
    urls = scan_params[:urls]&.split&.map(&:strip)

    options = build_options(scan_params)

    urls.each do |url|
      options[:url] = url
      ScanJob.perform_async(options.to_json)
    end

    redirect_to new_scan_path, notice: 'Scans started successfully.'
  end

  private

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
    params.require(:scan).permit(:urls, :crawl, :audit)
  end

  def check_settings
    missing_settings = Setting.any? { |v| v[:value].empty? }

    return unless missing_settings

    redirect_to settings_path, alert: 'Please fill in all required settings before launching a scan'
  end
end
