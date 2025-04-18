namespace :render do
  desc "Setup database for deployment"
  task setup_db: :environment do
    # Try to connect to the database
    begin
      # Check if the database exists and has tables
      if ActiveRecord::Base.connection.table_exists?(:schema_migrations)
        puts "Database already exists and has schema_migrations table. Skipping schema load."
      else
        puts "Database exists but schema_migrations table not found. Loading schema."
        
        # Load schema if migrations are available
        if File.exist?(Rails.root.join("db/schema.rb"))
          puts "Loading schema from schema.rb"
          Rake::Task["db:schema:load"].invoke
        else
          puts "Running migrations"
          Rake::Task["db:migrate"].invoke
        end
      end
      
      # Check if we need to seed the database
      if Article.count == 0
        puts "No articles found in database. Seeding database."
        # Seed the database if seeds are available
        if File.exist?(Rails.root.join("db/seeds.rb"))
          Rake::Task["db:seed"].invoke
          puts "Database seeded with #{Article.count} articles"
        else
          puts "No seeds.rb file found. Skipping seeding."
        end
      else
        puts "Database already contains #{Article.count} articles. Skipping seeding."
      end
      
      puts "Database setup complete"
    rescue => e
      puts "Error setting up database: #{e.message}"
      puts e.backtrace
      raise
    end
  end
  
  desc "Create databases for development and test"
  task create_local_dbs: :environment do
    # This task is meant to be run locally
    unless Rails.env.production?
      system("createdb searchbox_development") or puts "Failed to create development database (it may already exist)"
      system("createdb searchbox_test") or puts "Failed to create test database (it may already exist)"
      puts "Local PostgreSQL databases created (if they didn't already exist)"
    end
  end
end 