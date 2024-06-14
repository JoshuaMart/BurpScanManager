# frozen_string_literal: true

DRAGONFLY_URL = 'redis://dragonfly:6379/0'

Sidekiq.configure_server do |config|
  config.redis = { url: DRAGONFLY_URL }
end

Sidekiq.configure_client do |config|
  config.redis = { url: DRAGONFLY_URL }
end
