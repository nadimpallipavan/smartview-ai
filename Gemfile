source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Rails
gem "rails", "~> 7.1"
gem "sprockets-rails"
gem "pg", "~> 1.5"
gem "puma", "~> 6.4"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails", "~> 3.3"
gem "jbuilder"
gem "redis", ">= 4.0.1"
gem "bootsnap", require: false

# Authentication
gem "devise", "~> 4.9"

# Background Jobs
gem "sidekiq", "~> 7.2"

# AWS
gem "aws-sdk-s3", "~> 1.143"
gem "aws-sdk-rekognition", "~> 1.90"

# Image Processing
gem "image_processing", "~> 1.12"
gem "mini_magick", "~> 4.12"

# Active Storage
gem "activestorage", "~> 7.1"

# Encryption
gem "lockbox", "~> 1.3"

# Math / Matrix
gem "matrix"
gem "numo-narray", "~> 0.9"

# Pagination
gem "pagy", "~> 6.3"

# HTTP
gem "faraday", "~> 2.8"

# Environment variables
gem "dotenv-rails", groups: [:development, :test]

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
