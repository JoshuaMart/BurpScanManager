# frozen_string_literal: true

# VulnerabilitiesHelper
module VulnerabilitiesHelper
	def vulnerability_class(status)
    case status
    when 'high'
      'danger'
    when 'medium'
      'success'
    else
      'secondary'
    end
  end
end
