# frozen_string_literal: true

# VulnerabilitiesController
class VulnerabilitiesController < ApplicationController
  def index
    @vulnerabilities = Vulnerability.where(status: 'new')
  end

  def show
    @vulnerability = Vulnerability.find(params[:id])
  end

  def triage
    vulnerability = Vulnerability.find(params[:id])
    vulnerability.update(status: 'triaged')

    redirect_to vulnerabilities_path, notice: 'Vulnerability was successfully triaged.'
  end
end
