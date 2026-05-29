require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.assets.compile = false

  # Use S3 only when real AWS credentials are configured; otherwise fall back
  # to local disk so the app deploys and runs without an S3 bucket.
  config.active_storage.service =
    if ENV["AWS_ACCESS_KEY_ID"].present? && ENV["AWS_S3_BUCKET"].present?
      :amazon
    else
      :local
    end

  config.force_ssl = true
  # Don't redirect the health check to HTTPS — Render probes it internally over
  # HTTP, and a 301 redirect would make the deploy look unhealthy.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/health" } } }

  # Allow the Render-assigned hostname (and any custom domain) through
  # Rails host authorization. RENDER_EXTERNAL_HOSTNAME is set by Render.
  config.hosts << ENV["RENDER_EXTERNAL_HOSTNAME"] if ENV["RENDER_EXTERNAL_HOSTNAME"].present?
  config.hosts << /.*\.onrender\.com/
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
  config.log_tags = [:request_id]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
end
