require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SmartviewAi
  class Application < Rails::Application
    config.load_defaults 7.1

    # Autoload lib directory
    config.autoload_lib(ignore: %w[assets tasks])

    # Time zone
    config.time_zone = "UTC"

    # Active Job queue adapter
    config.active_job.queue_adapter = :sidekiq

    # Active Storage
    config.active_storage.variant_processor = :mini_magick

    # Active Record Encryption
    config.active_record.encryption.primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY", "smartview-primary-key-dev-only-32chars!")
    config.active_record.encryption.deterministic_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY", "smartview-det-key-dev-only-32ch!")
    config.active_record.encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT", "smartview-salt-dev-only")

    # Generators
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.stylesheets false
      g.helper false
    end
  end
end
