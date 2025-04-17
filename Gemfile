source "https://rubygems.org"

# Core Rails gems
gem "rails", "~> 8.0.2"
gem "propshaft" # Asset pipeline
gem "sqlite3", ">= 2.1" # Database
gem "puma", ">= 5.0" # Web server
gem "jbuilder" # JSON API support

# Cross-platform support
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Performance optimization
gem "bootsnap", require: false

# Redis for caching (needed for analytics)
gem 'redis'
gem 'connection_pool'

group :development, :test do
  gem "debug", platforms: %i[ mri mswin mswin64 mingw x64_mingw ]
  gem "faker", "~> 3.0" # For sample data generation
end

group :development do
  gem "web-console"
end
