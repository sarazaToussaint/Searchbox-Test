require 'redis'
require 'connection_pool'

redis_config = {
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
  driver: :hiredis,
  timeout: 1
}

# Set up a connection pool for Redis
REDIS_POOL = ConnectionPool.new(size: 10, timeout: 5) do
  Redis.new(redis_config)
end

# Make Redis.current work for direct access
Redis.current = Redis.new(redis_config) 