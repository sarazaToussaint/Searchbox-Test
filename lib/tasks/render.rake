namespace :render do
  desc "Setup database for Render deployment"
  task setup_db: :environment do
    # Only run if the database exists
    if ActiveRecord::Base.connection.table_exists?(:schema_migrations)
      puts "Database already exists and has schema_migrations table. Skipping setup."
      next
    end
    
    # Create the PostgreSQL database
    puts "Setting up database for Render deployment"
    
    # Load schema if migrations are available
    if File.exist?(Rails.root.join("db/schema.rb"))
      puts "Loading schema from schema.rb"
      Rake::Task["db:schema:load"].invoke
    else
      puts "Running migrations"
      Rake::Task["db:migrate"].invoke
    end
    
    # Seed the database if seeds are available
    if File.exist?(Rails.root.join("db/seeds.rb"))
      puts "Seeding database"
      Rake::Task["db:seed"].invoke
    end
    
    puts "Database setup complete"
  rescue => e
    puts "Error setting up database: #{e.message}"
    puts e.backtrace
    raise
  end
end 