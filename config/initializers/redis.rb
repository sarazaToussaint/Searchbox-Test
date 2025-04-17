require 'redis'
require 'connection_pool'

redis_config = {
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
  timeout: 1
}

# Set up a connection pool for Redis
REDIS_POOL = ConnectionPool.new(size: 10, timeout: 5) do
  Redis.new(redis_config)
end

# Note: Redis.current is deprecated in newer versions of the Redis gem.
# Use REDIS_POOL.with { |redis| redis.get(...) } for thread-safe access. 