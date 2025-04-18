class ArticlesController < ApplicationController
  # GET /articles
  # GET /articles.json
  def index
    begin
      @articles = Article.all
      ensure_user_identifier
      
      respond_to do |format|
        format.html
        format.json { render json: @articles }
      end
    rescue => e
      handle_generic_error(e, "Error loading articles")
    end
  end
  
  # GET /articles/search
  # Handles real-time article search with analytics
  def search
    query = params[:query].to_s.strip
    is_final = params[:is_final] == 'true'
    
    begin
      # Search for articles
      @articles = query.blank? ? Article.all : Article.search_by_title_and_content(query)
      
      # Process analytics for final searches
      if is_final && !query.blank?
        process_final_search(query, @articles)
      end
      
      # Prepare analytics data for response
      analytics_data = prepare_analytics_data(is_final, query)
      
      # Return response
      respond_to do |format|
        format.json { render json: { articles: @articles, total: @articles.count, analytics: analytics_data } }
        format.html { render :index }
      end
    rescue => e
      Rails.logger.error("Search error: #{e.message}")
      handle_search_error
    end
  end
  
  # GET /articles/analytics
  # Returns analytics data for the current user
  def analytics
    user_id = ensure_user_identifier
    
    # Try to get from cache first
    cached_analytics = fetch_cached_analytics(user_id)
    
    if cached_analytics
      load_analytics_from_cache(cached_analytics)
    else
      load_analytics_from_database(user_id)
      cache_analytics_data(user_id)
    end
    
    respond_to do |format|
      format.json { render json: format_analytics_response(user_id) }
      format.html { render :index }
    end
  end
  
  # GET /articles/my_searches
  # Returns current user's search history
  def my_searches
    user_id = ensure_user_identifier
    @searches = SearchQuery.top_searches_for_user(user_id, 20)
    
    respond_to do |format|
      format.json {
        render json: {
          user_identifier: user_id,
          searches: @searches.map { |sq| format_search_query(sq) }
        }
      }
      format.html { render :index }
    end
  end
  
  # GET /articles/ip_searches
  # Returns searches from the current IP address
  def ip_searches
    ip = params[:ip] || request.remote_ip
    @searches = SearchQuery.top_searches_from_ip(ip, 20)
    
    respond_to do |format|
      format.json { render json: { ip_address: ip, searches: @searches } }
      format.html { render :index }
    end
  end
  
  # GET /articles/my_top_articles
  # Returns most viewed articles for the current user
  def my_top_articles
    user_id = ensure_user_identifier
    @articles = Article.top_appearing_for_user(user_id, 20)
    
    respond_to do |format|
      format.json {
        render json: {
          user_identifier: user_id,
          articles: @articles.map { |a| format_article(a, user_id) }
        }
      }
      format.html { render :index }
    end
  end
  
  # POST /articles/set_user_identifier
  # Sets the user identifier from the client
  def set_user_identifier
    if params[:user_id].present?
      user_id = params[:user_id]
      cookies.permanent[:user_identifier] = user_id
      session[:user_identifier] = user_id
      
      respond_to do |format|
        format.json { render json: { success: true, user_identifier: user_id } }
        format.html { redirect_to root_path }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: "No user_id provided" }, status: :bad_request }
        format.html { redirect_to root_path, alert: "No user ID provided" }
      end
    end
  end
  
  # POST /articles/process_pending_searches
  # Process pending searches from client (for offline support)
  def process_pending_searches
    user_id = ensure_user_identifier
    ip_address = request.remote_ip
    pending_searches = params[:pending_searches]
    
    if pending_searches.present? && pending_searches.is_a?(Array)
      processed = process_batch_searches(pending_searches, user_id, ip_address)
      
      respond_to do |format|
        format.json { render json: { success: true, processed: processed } }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: "Invalid pending searches data" }, status: :bad_request }
      end
    end
  end
  
  # GET /articles/debug_info
  # Debug endpoint for troubleshooting
  def debug_info
    begin
      info = {
        rails_env: Rails.env,
        database_adapter: ActiveRecord::Base.connection.adapter_name,
        database_version: ActiveRecord::Base.connection.select_value('SELECT version()'),
        ruby_version: RUBY_VERSION,
        rails_version: Rails::VERSION::STRING,
        timestamp: Time.current.to_s,
        user_identifier: ensure_user_identifier,
        ip_address: request.remote_ip,
        article_count: Article.count,
        search_query_count: SearchQuery.count,
        article_view_count: ArticleView.count
      }
      
      respond_to do |format|
        format.json { render json: info }
        format.html { render plain: info.map { |k, v| "#{k}: #{v}" }.join("\n") }
      end
    rescue => e
      handle_generic_error(e, "Error fetching debug info")
    end
  end
  
  private
  
  # Process a final search term
  def process_final_search(query, articles)
    begin
      user_identifier = ensure_user_identifier
      ip_address = request.remote_ip
      
      # Save search analytics
      process_search_analytics(query, user_identifier, ip_address, articles.count)
      
      # Track article appearances
      track_article_appearances(articles, user_identifier) if articles.any?
    rescue => e
      Rails.logger.error("Search analytics error: #{e.message}")
    end
  end
  
  # Process a batch of searches
  def process_batch_searches(searches, user_id, ip_address)
    processed = 0
    
    searches.each do |search_data|
      search_term = search_data[:query].to_s.strip
      next if search_term.blank?
      
      # Get results count for this search
      results_count = Article.search_by_title_and_content(search_term).count
      
      # Process search analytics
      process_search_analytics(search_term, user_id, ip_address, results_count)
      processed += 1
    end
    
    processed
  end
  
  # Save search analytics to database
  def process_search_analytics(search_term, user_identifier, ip_address, results_count)
    # Wrap in a transaction for atomicity
    ActiveRecord::Base.transaction do
      # Find or initialize the search query
      search_query = SearchQuery.find_or_initialize_by(
        term: search_term,
        user_identifier: user_identifier,
        ip_address: ip_address
      )

      # Set up the record attributes
      search_query.search_count ||= 0
      search_query.search_count += 1
      search_query.results_count = results_count
      search_query.last_searched_at = Time.current

      # Save the record
      if search_query.save
        # Delete similar searches to keep analytics clean
        search_query.delete_similar_searches
      end
    end
  end
  
  # Track article appearances in search results
  def track_article_appearances(articles, user_identifier)
    articles.each do |article|
      article.increment_appearances_count(user_identifier)
    end
  end
  
  # Prepare analytics data for search response
  def prepare_analytics_data(is_final, query)
    user_id = ensure_user_identifier
    {
      top_searches: SearchQuery.top_search_terms_for_user(user_id) || [],
      trending_searches: SearchQuery.top_searches.limit(5) || [],
      user_identifier: user_id,
      ip_address: request.remote_ip,
      is_final_search: is_final,
      search_saved: is_final && !query.blank?
    }
  end
  
  # Handle search error with graceful response
  def handle_search_error
    respond_to do |format|
      format.json {
        render json: {
          articles: [],
          total: 0,
          error: "An error occurred during search",
          analytics: {
            user_identifier: ensure_user_identifier,
            ip_address: request.remote_ip
          }
        }, status: :internal_server_error
      }
      format.html { 
        @articles = []
        flash[:error] = "An error occurred during search. Please try again."
        render :index 
      }
    end
  end
  
  # Handle generic error
  def handle_generic_error(error, message)
    Rails.logger.error("#{message}: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n"))
    
    respond_to do |format|
      format.html { 
        flash[:error] = "#{message}. Please try again later."
        render :index 
      }
      format.json { 
        render json: { 
          error: message,
          status: 500
        }, status: :internal_server_error 
      }
    end
  end
  
  # Load analytics from cache
  def load_analytics_from_cache(cached_data)
    @top_searches = cached_data[:top_searches]
    @top_articles = cached_data[:top_articles]
    @total_unique_searches = cached_data[:total_unique_searches]
    @total_articles_found = cached_data[:total_articles_found]
    @total_appearances = cached_data[:total_appearances]
  end
  
  # Load analytics from database
  def load_analytics_from_database(user_id)
    @top_searches = SearchQuery.top_searches_for_user(user_id, 10)
    @top_articles = Article.top_appearing_for_user(user_id, 10)
    
    # Calculate additional statistics
    @total_unique_searches = SearchQuery.where(user_identifier: user_id).count
    @total_articles_found = ArticleView.joins(:search_query)
                                     .where(search_queries: { user_identifier: user_id })
                                     .select("DISTINCT article_id").count
    @total_appearances = ArticleView.joins(:search_query)
                                  .where(search_queries: { user_identifier: user_id }).count
  end
  
  # Format analytics response
  def format_analytics_response(user_id)
    {
      user_identifier: user_id,
      top_searches: @top_searches.map { |sq| format_search_query(sq) },
      top_articles: @top_articles.map { |a| format_article(a, user_id) },
      stats: {
        total_unique_searches: @total_unique_searches || 0,
        total_articles_found: @total_articles_found || 0,
        total_appearances: @total_appearances || 0
      }
    }
  end
  
  # Format search query for API response
  def format_search_query(sq)
    { 
      id: sq.id,
      term: sq.term,
      search_count: sq.search_count,
      results_count: sq.results_count,
      last_searched_at: sq.last_searched_at
    }
  end
  
  # Format article for API response
  def format_article(article, user_id)
    { 
      id: article.id,
      title: article.title,
      author: article.author,
      category: article.category,
      appearances: article.appearance_count_for_user(user_id)
    }
  end
  
  # Fetch analytics from cache
  def fetch_cached_analytics(user_id)
    begin
      key = "user_analytics:#{user_id}"
      cached = REDIS_POOL.with { |redis| redis.get(key) }
      cached ? JSON.parse(cached, symbolize_names: true) : nil
    rescue => e
      Rails.logger.error("Error fetching cached analytics: #{e.message}")
      nil
    end
  end
  
  # Cache analytics data
  def cache_analytics_data(user_id)
    begin
      key = "user_analytics:#{user_id}"
      data = {
        top_searches: @top_searches,
        top_articles: @top_articles,
        total_unique_searches: @total_unique_searches,
        total_articles_found: @total_articles_found,
        total_appearances: @total_appearances
      }
      REDIS_POOL.with { |redis| redis.set(key, data.to_json, ex: 5.minutes.to_i) }
    rescue => e
      Rails.logger.error("Error caching analytics: #{e.message}")
    end
  end
  
  # Ensure a user identifier is available
  def ensure_user_identifier
    begin
      # Get user identifier from cookie or session
      user_id = cookies[:user_identifier] || session[:user_identifier]
      
      # Generate a new one if none exists
      if user_id.blank?
        user_id = SecureRandom.uuid
        cookies.permanent[:user_identifier] = user_id
        session[:user_identifier] = user_id
      end
      
      user_id
    rescue => e
      Rails.logger.error("Error ensuring user identifier: #{e.message}")
      "anonymous-#{SecureRandom.hex(8)}" # Fallback anonymous ID
    end
  end
end 