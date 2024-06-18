# frozen_string_literal: true

# HomeController
class HomeController < ApplicationController
  # GET /
  def index
    @scan_statuses = ScanStatus.all
  end
end
