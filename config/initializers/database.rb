# Database configuration for PostgreSQL in production
if Rails.env.production?
  Rails.application.config.after_initialize do
    ActiveRecord::Base.connection_pool.disconnect! rescue nil
    
    ActiveSupport.on_load(:active_record) do
      database_url = ENV['DATABASE_URL']
      if database_url
        Rails.logger.info "Connecting to PostgreSQL database with DATABASE_URL from environment"
      else
        # Construct the URL from individual components if DATABASE_URL is not provided
        host = ENV.fetch('POSTGRES_HOST', 'localhost')
        port = ENV.fetch('POSTGRES_PORT', '5432')
        database = ENV.fetch('POSTGRES_DB', 'searchbox_db')
        username = ENV.fetch('POSTGRES_USER', 'searchbox_user')
        password = ENV.fetch('POSTGRES_PASSWORD', '')
        
        database_url = "postgres://#{username}:#{password}@#{host}:#{port}/#{database}"
        Rails.logger.info "Connecting to PostgreSQL database with constructed URL from environment variables"
      end
      
      # Set up the connection
      begin
        db_config = URI.parse(database_url)
        config = {
          adapter: 'postgresql',
          encoding: 'unicode',
          pool: ENV.fetch("RAILS_MAX_THREADS") { 5 },
          database: db_config.path.delete_prefix('/'),
          username: db_config.user,
          password: db_config.password,
          host: db_config.host,
          port: db_config.port || 5432
        }
        ActiveRecord::Base.establish_connection(config)
        Rails.logger.info "Successfully connected to PostgreSQL database"
      rescue => e
        Rails.logger.error "Failed to connect to PostgreSQL database: #{e.message}"
        raise
      end
    end
  end
end 