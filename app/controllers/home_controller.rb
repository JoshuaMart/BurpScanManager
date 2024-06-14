# frozen_string_literal: true

# HomeController
class HomeController < ApplicationController
  # GET /
  def index
    render template: 'home/index'
  end
end
