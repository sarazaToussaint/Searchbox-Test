namespace :render do
  desc "Tasks for Render deployment"
  
  task :setup_db => :environment do
    # Only run in production environment
    if Rails.env.production?
      begin
        # Check if this is a PostgreSQL connection
        if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
          puts "Setting up PostgreSQL database for Render deployment..."
          
          # Make sure we have all the latest migrations
          Rake::Task["db:migrate"].invoke
          
          # Check if the database needs to be seeded
          if Article.count == 0
            puts "Database is empty, seeding with initial data..."
            Rake::Task["db:seed"].invoke
          else
            puts "Database already contains data, skipping seed."
          end
        else
          puts "Not using PostgreSQL, running standard setup..."
          Rake::Task["db:migrate"].invoke
          
          if Article.count == 0
            Rake::Task["db:seed"].invoke
          end
        end
        
        puts "Database setup completed successfully."
      rescue => e
        puts "Error during database setup: #{e.message}"
        puts e.backtrace
        raise e
      end
    else
      puts "This task is intended for production environment only."
    end
  end
end 