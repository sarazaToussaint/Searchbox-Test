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
      # Log the error
      Rails.logger.error("Error in articles#index: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      
      # Return a friendly error response
      respond_to do |format|
        format.html { 
          @articles = []
          flash[:error] = "An error occurred while loading articles. Please try again later."
          render :index
        }
        format.json { 
          render json: { 
            error: "An error occurred while loading articles",
            status: 500,
            message: "Please try the debug_info endpoint for more details"
          }, status: :internal_server_error 
        }
      end
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
        begin
          user_identifier = ensure_user_identifier
          ip_address = request.remote_ip
          
          # Save search analytics
          process_search_analytics(query, user_identifier, ip_address, @articles.count)
          
          # Track article appearances
          track_article_appearances(@articles, user_identifier) if @articles.any?
        rescue => e
          Rails.logger.error("Search analytics error: #{e.message}")
        end
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
      
      # Cache the analytics data
      cache_analytics_data(user_id, {
        top_searches: @top_searches,
        top_articles: @top_articles,
        total_unique_searches: @total_unique_searches,
        total_articles_found: @total_articles_found,
        total_appearances: @total_appearances
      })
    end
    
    # Handle different data scope based on params
    apply_analytics_scope(params, user_id)
    
    respond_to do |format|
      format.json { render json: format_analytics_response(user_id) }
      format.html { render :index }
    end
  end
  
  # GET /articles/my_searches
  # Returns current user's search history
  def my_searches
    user_id = params[:user_id] || ensure_user_identifier
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
    user_id = params[:user_id] || ensure_user_identifier
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
    
    # Get pending searches from params
    pending_searches = params[:pending_searches]
    
    if pending_searches.present? && pending_searches.is_a?(Array)
      processed = 0
      
      # Process each pending search
      pending_searches.each do |search_data|
        search_term = search_data[:query].to_s.strip
        next if search_term.blank?
        
        # Get results count for this search
        results_count = Article.search_by_title_and_content(search_term).count
        
        # Process search analytics
        process_search_analytics(search_term, user_id, ip_address, results_count)
        processed += 1
      end
      
      respond_to do |format|
        format.json { render json: { success: true, processed: processed } }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: "Invalid pending searches data" }, status: :bad_request }
      end
    end
  end
  
  # Add the debug endpoint right after the index action
  def debug_info
    begin
      result = {
        environment: Rails.env,
        database_config: ActiveRecord::Base.connection.pool.spec.config.except(:password),
        database_tables: ActiveRecord::Base.connection.tables,
        article_count: Article.count,
        search_query_count: SearchQuery.count,
        article_view_count: ArticleView.count,
        rails_version: Rails.version,
        ruby_version: RUBY_VERSION,
        cookie_consent: cookies[:user_identifier].present?,
        session_active: session[:user_identifier].present?,
        ip_address: request.remote_ip
      }
      
      # Try to get articles
      begin
        articles = Article.limit(2).to_a
        result[:sample_article] = articles.first.attributes if articles.any?
      rescue => e
        result[:articles_error] = e.message
        result[:articles_backtrace] = e.backtrace.first(5)
      end
      
      # Check search queries
      begin
        if SearchQuery.any?
          result[:sample_query] = SearchQuery.first.attributes
        end
      rescue => e
        result[:queries_error] = e.message
      end
      
      # Check Redis
      begin
        redis_ping = REDIS_POOL.with { |redis| redis.ping }
        result[:redis_ping] = redis_ping
      rescue => e
        result[:redis_error] = e.message
      end
      
      render json: result
    rescue => e
      render json: {
        error: e.message,
        backtrace: e.backtrace.first(10)
      }
    end
  end
  
  private
  
  # Process search analytics directly
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
        SearchQuery.where(user_identifier: user_identifier)
                 .where("term LIKE ? AND term != ? AND id != ?", 
                       "#{search_term.first(search_term.length/2)}%", 
                       search_term, 
                       search_query.id)
                 .destroy_all
      end
    end
  end
  
  # Track article appearances in search results
  def track_article_appearances(articles, user_identifier)
    articles.each do |article|
      if article.respond_to?(:increment_appearances_count)
        article.increment_appearances_count(user_identifier)
      end
    end
  end
  
  # Prepare analytics data for search response
  def prepare_analytics_data(is_final, query)
    {
      top_searches: begin
                      SearchQuery.top_search_terms_for_user(ensure_user_identifier)
                    rescue
                      []
                    end,
      trending_searches: begin
                           SearchQuery.top_searches.limit(5)
                         rescue
                           []
                         end,
      user_identifier: ensure_user_identifier,
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
  
  # Apply different scope to analytics based on params
  def apply_analytics_scope(params, user_id)
    @is_user_specific = true
    
    # Global data
    if params[:global] == 'true'
      @top_searches = SearchQuery.order(search_count: :desc).limit(10)
      @top_articles = Article.top_appearing(10)
      @total_unique_searches = SearchQuery.count('DISTINCT term')
      @total_articles_found = Article.joins(:article_views).distinct.count
      @total_appearances = ArticleView.count
      @is_user_specific = false
      
    # Specific user data  
    elsif params[:user_id].present? && params[:user_id] != user_id
      specified_user_id = params[:user_id]
      @top_searches = SearchQuery.top_searches_for_user(specified_user_id, 10)
      @top_articles = Article.top_appearing_for_user(specified_user_id, 10)
      @total_unique_searches = SearchQuery.where(user_identifier: specified_user_id).count
      @total_articles_found = ArticleView.joins(:search_query)
                                       .where(search_queries: { user_identifier: specified_user_id })
                                       .select("DISTINCT article_id").count
      @total_appearances = ArticleView.joins(:search_query)
                                    .where(search_queries: { user_identifier: specified_user_id }).count
                                    
    # IP-specific data
    elsif params[:ip].present?
      @top_searches = SearchQuery.top_searches_from_ip(params[:ip], 10)
    end
  end
  
  # Format analytics response for JSON
  def format_analytics_response(user_id)
    {
      user_identifier: user_id,
      ip_address: request.remote_ip,
      is_user_specific: @is_user_specific,
      top_searches: @top_searches.map { |sq| format_search_query_response(sq) },
      top_articles: @top_articles.map { |a| format_article(a, user_id) },
      stats: {
        total_unique_searches: @total_unique_searches,
        total_articles_found: @total_articles_found,
        total_appearances: @total_appearances
      }
    }
  end
  
  # Format search query for response
  def format_search_query_response(sq)
    if sq.is_a?(String)
      { term: sq, count: 1, results: 0, last_searched: Time.current }
    else
      { 
        term: sq.term, 
        count: sq.search_count,
        results: sq.results_count,
        last_searched: sq.last_searched_at,
        user_identifier: sq.user_identifier,
        ip_address: sq.ip_address
      }
    end
  end
  
  # Format search query object
  def format_search_query(sq)
    { 
      term: sq.term, 
      count: sq.search_count,
      results: sq.results_count,
      last_searched: sq.last_searched_at
    }
  end
  
  # Format article for response
  def format_article(article, user_id)
    { 
      id: article.id,
      title: article.title, 
      category: article.category,
      appearances: article.appearance_count_for_user(user_id)
    }
  end
  
  # Helper method to fetch cached analytics data
  def fetch_cached_analytics(user_id)
    begin
      cached_data = REDIS_POOL.with do |redis|
        redis.get("analytics:#{user_id}")
      end
      
      return nil unless cached_data
      
      # Parse the JSON data
      JSON.parse(cached_data, symbolize_names: true)
    rescue => e
      Rails.logger.error("Error fetching cached analytics: #{e.message}")
      nil
    end
  end
  
  # Helper method to cache analytics data
  def cache_analytics_data(user_id, data)
    begin
      # Cache data for 5 minutes
      REDIS_POOL.with do |redis|
        redis.setex("analytics:#{user_id}", 300, data.to_json)
      end
    rescue => e
      Rails.logger.error("Error caching analytics data: #{e.message}")
    end
  end
  
  # Ensure user has a persistent identifier
  def ensure_user_identifier
    begin
      # Try to get from cookies first (most persistent)
      # Then from session, and finally generate a new one if needed
      user_id = cookies.permanent[:user_identifier]
      
      if user_id.blank?
        # If cookie is empty, try session
        user_id = session[:user_identifier]
        
        if user_id.blank?
          # If both are empty, generate a new identifier
          user_id = SecureRandom.uuid
        end
        
        # Always ensure both storage mechanisms have the identifier
        cookies.permanent[:user_identifier] = user_id
      end
      
      # Also set in session for this request
      session[:user_identifier] = user_id
      
      # Return the user identifier
      user_id
    rescue => e
      # Log the error but don't crash the app
      Rails.logger.error("Error in ensure_user_identifier: #{e.message}")
      
      # Generate a temporary ID for this request only
      SecureRandom.uuid
    end
  end
end 