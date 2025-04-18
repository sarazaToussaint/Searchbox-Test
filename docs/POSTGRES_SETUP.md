# PostgreSQL Setup for Searchbox

This application now uses PostgreSQL for all environments (development, test, and production). This document provides instructions for setting up PostgreSQL locally.

## Prerequisites

1. PostgreSQL installed on your local machine
   - macOS: `brew install postgresql@15` (or newer version)
   - Ubuntu/Debian: `sudo apt-get install postgresql`
   - Windows: Download installer from https://www.postgresql.org/download/windows/

2. Make sure PostgreSQL service is running
   - macOS: `brew services start postgresql@15`
   - Ubuntu/Debian: `sudo service postgresql start`
   - Windows: Services app > PostgreSQL service > Start

## Setup

### Option 1: Automatic Setup (Recommended)

Run the setup script:

```bash
./bin/setup-postgres
```

To set up and seed the database with sample data:

```bash
./bin/setup-postgres --seed
```

### Option 2: Manual Setup

1. Create the development and test databases:

```bash
createdb searchbox_development
createdb searchbox_test
```

2. Run migrations:

```bash
bundle exec rails db:migrate
```

3. (Optional) Seed the database:

```bash
bundle exec rails db:seed
```

## Configuration

The application uses the following environment variables for PostgreSQL configuration:

- `POSTGRES_HOST`: PostgreSQL host (default: `localhost`)
- `POSTGRES_PORT`: PostgreSQL port (default: `5432`)
- `POSTGRES_USER`: PostgreSQL username (default: `postgres`)
- `POSTGRES_PASSWORD`: PostgreSQL password (default: empty string)

You can set these variables in your `.env` file or directly in your environment.

## Troubleshooting

### Connection Issues

If you cannot connect to PostgreSQL, check:

1. PostgreSQL service is running
2. Your PostgreSQL user has permission to create databases
3. Your password is correctly set in the environment variables

### Authentication Issues

If you're getting authentication errors:

1. Check your PostgreSQL configuration in `pg_hba.conf`
2. Ensure your user has appropriate permissions
3. Verify your password is correct 