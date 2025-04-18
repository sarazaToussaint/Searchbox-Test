# Deploying to Render

This document provides instructions for deploying the Searchbox application to Render and fixing any potential database issues.

## Automated Deployment

The application is configured with a `render.yaml` file that sets up the web service and PostgreSQL database automatically. When you deploy to Render:

1. Connect your GitHub repository to Render
2. Render will use the `render.yaml` configuration file
3. The custom `bin/render-deploy` script will run to:
   - Set up the PostgreSQL database
   - Run migrations
   - Seed the database with initial data
   - Start the Rails server

## Environment Variables

Make sure the following environment variables are set in your Render dashboard:

- `RAILS_MASTER_KEY` - Your Rails master key for decrypting credentials
- `DATABASE_URL` - Should be automatically set by Render if using their PostgreSQL service
- `RAILS_ENV` - Set to `production`
- `RAILS_LOG_TO_STDOUT` - Set to `true`
- `DISABLE_DATABASE_ENVIRONMENT_CHECK` - Set to `1` if you need to reset the database

## Manual Database Setup

If you need to manually set up the database (for example, if tables are not created automatically):

1. Open a shell in your Render dashboard for the web service
2. Run the database fix script:

```bash
bin/fix-render-db
```

This script will:
- Load the schema
- Run migrations
- Seed the database
- Show the current database state

## Troubleshooting Database Issues

If you encounter database issues, try these steps:

1. **Check database connection**:
   ```bash
   bundle exec rails runner "puts ActiveRecord::Base.connection.active?"
   ```

2. **List tables**:
   ```bash
   bundle exec rails runner "puts ActiveRecord::Base.connection.tables.join(', ')"
   ```

3. **Check data counts**:
   ```bash
   bundle exec rails runner "puts \"Articles: #{Article.count}\nSearch Queries: #{SearchQuery.count}\nArticle Views: #{ArticleView.count}\""
   ```

4. **Manual schema load**:
   ```bash
   DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:schema:load
   ```

5. **Manual seed**:
   ```bash
   bundle exec rails db:seed
   ```

## PostgreSQL Instance on Render

Ensure your PostgreSQL instance on Render:
- Is in the same region as your web service
- Has the correct database name (`searchbox_db`)
- Has the proper access permissions

If you need to completely reset your database, you can use:
```bash
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:reset
```

**Note**: Be careful with `db:reset` in production as it will delete all data! 