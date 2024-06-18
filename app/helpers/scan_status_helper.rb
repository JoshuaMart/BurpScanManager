# frozen_string_literal: true

# ScanStatusHelper
module ScanStatusHelper
  def status_class(status)
    case status
    when 'Waiting', 'In Progress'
      'primary'
    when 'Finished'
      'success'
    when 'Error'
      'danger'
    else
      'secondary'
    end
  end
end