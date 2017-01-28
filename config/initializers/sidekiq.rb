Sidekiq.configure_server do |config|
  config.redis = { url: "#{Rails.application.secrets.redis_url}/0/pg2rs" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "#{Rails.application.secrets.redis_url}/0/pg2rs" }
end

Sidekiq::Logging.logger.level = Logger::WARN
