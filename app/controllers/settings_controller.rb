# frozen_string_literal: true

# app/controllers/settings_controller.rb
class SettingsController < ApplicationController
  def index
    @settings = Setting.order(:id)
  end

  def update
    setting_params&.each do |id, value|
      setting = Setting.find(id)
      setting.update(value:)
    end

    redirect_to settings_path, notice: 'Settings updated successfully.'
  end

  private

  def setting_params
    params.require(:settings)
  end
end
