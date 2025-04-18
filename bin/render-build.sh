# Exit on error
set -o errexit

bundle install

# Run database setup
bundle exec rails db:migrate
bundle exec rails db:seed

# Precompile assets
bundle exec rails assets:precompile
bundle exec rails assets:clean