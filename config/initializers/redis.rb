require 'redis'
require 'connection_pool'

begin
  redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  
  # For Render.com deployment
  redis_config = {
    url: redis_url,
    timeout: 5,  # Increased timeout for cloud environments
    reconnect_attempts: 3
  }

  # Set up a connection pool for Redis
  REDIS_POOL = ConnectionPool.new(size: 5, timeout: 5) do
    Redis.new(redis_config)
  end

  # Test the connection
  REDIS_POOL.with { |redis| redis.ping }
  
  Rails.logger.info "Redis connection established successfully" if defined?(Rails)
rescue => e
  # Log error but allow app to start in environments where Redis might not be available
  if defined?(Rails)
    Rails.logger.error "Failed to initialize Redis: #{e.message}"
    Rails.logger.error "Redis will be unavailable - some features may not work correctly"
  else
    puts "Failed to initialize Redis: #{e.message}"
    puts "Redis will be unavailable - some features may not work correctly"
  end
  
  # Provide a dummy Redis pool that won't crash the app
  REDIS_POOL = Object.new
  def REDIS_POOL.with
    yield DummyRedis.new
  end
  
  # Dummy Redis class that logs operations but doesn't do anything
  class DummyRedis
    def method_missing(method, *args, &block)
      if defined?(Rails)
        Rails.logger.warn "Redis call to #{method} failed - Redis is not available"
      end
      nil
    end
    
    def ping
      "DUMMY"
    end
  end
end

# Note: Redis.current is deprecated in newer versions of the Redis gem.
# Use REDIS_POOL.with { |redis| redis.get(...) } for thread-safe access. 