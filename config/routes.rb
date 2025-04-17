Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path route
  root 'articles#index'
  
  # Articles routes
  resources :articles, only: [:index] do
    collection do
      get 'search'         # Search articles
      get 'analytics'      # Get analytics data
      post 'set_user_identifier'   # Set user identifier
      post 'process_pending_searches'  # Process searches stored during offline
      
      # Additional analytics endpoints
      get 'my_searches'    # Current user's searches
      get 'ip_searches'    # Searches from current IP
      get 'my_top_articles'  # Current user's top articles
    end
  end
end
