require 'redis'
require 'connection_pool'

begin
  redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  
  # Set up a connection pool for Redis
  REDIS_POOL = ConnectionPool.new(size: 5, timeout: 5) do
    Redis.new(
      url: redis_url,
      timeout: 5,
      reconnect_attempts: 3
    )
  end

  # Test the connection
  REDIS_POOL.with { |redis| redis.ping }
  Rails.logger.info "Redis connection established successfully"
rescue => e
  Rails.logger.error "Failed to initialize Redis: #{e.message}"
  Rails.logger.error "Fallback to dummy Redis - some features may not work correctly"
  
  # Provide a dummy Redis pool that won't crash the app
  REDIS_POOL = ConnectionPool.new(size: 1) do
    Class.new do
      def method_missing(method, *args, &block)
        Rails.logger.warn "Redis call to #{method} failed - Redis is not available"
        nil
      end
      
      def ping
        "DUMMY"
      end
    end.new
  end
end

# Helper method for easier Redis access
def with_redis(&block)
  REDIS_POOL.with(&block)
end

# Note: Redis.current is deprecated in newer versions of the Redis gem.
# Use REDIS_POOL.with { |redis| redis.get(...) } for thread-safe access. 