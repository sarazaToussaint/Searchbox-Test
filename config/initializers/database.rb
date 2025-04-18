# Database configuration for PostgreSQL in all environments
Rails.application.config.after_initialize do
  # Log the current database connection info
  begin
    adapter = ActiveRecord::Base.connection.adapter_name
    database = ActiveRecord::Base.connection.current_database
    Rails.logger.info "Connected to database: #{database} using adapter: #{adapter}"
    
    # Log PostgreSQL version
    if adapter.downcase.include?('postgresql')
      version = ActiveRecord::Base.connection.select_value('SELECT version()')
      Rails.logger.info "PostgreSQL version: #{version}"
    end
  rescue => e
    Rails.logger.error "Failed to log database connection info: #{e.message}"
  end
end 