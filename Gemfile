source "https://rubygems.org"

# Core Rails gems
gem "rails", "~> 8.0.2"
gem "pg", ">= 1.1" # PostgreSQL database
gem "puma", ">= 5.0" # Web server
gem "propshaft" # Asset pipeline (lightweight replacement for Sprockets)

# Utilities
gem "jbuilder" # JSON API support
gem "dotenv-rails" # Load environment variables from .env file
gem "bootsnap", require: false # Speed up boot time

# Redis for caching
gem 'redis'
gem 'connection_pool'

# Cross-platform support
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri mswin mswin64 mingw x64_mingw ]
  gem "faker", "~> 3.0" # For sample data generation
end

group :development do
  gem "web-console"
end
