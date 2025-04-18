class Article < ApplicationRecord
  has_many :article_views, dependent: :destroy
  has_many :search_queries, through: :article_views
  
  validates :title, presence: true
  validates :content, presence: true
  
  # Search articles by title and content
  def self.search_by_title_and_content(query)
    # Clean the query to prevent SQL injection
    sanitized_query = query.to_s.strip
    
    # Return all records if query is blank
    return all if sanitized_query.blank?
    
    # Use different syntax depending on database adapter
    if connection.adapter_name.downcase.include?('postgresql')
      where("title ILIKE ? OR content ILIKE ?", "%#{sanitized_query}%", "%#{sanitized_query}%")
    else
      where("title LIKE ? OR content LIKE ?", "%#{sanitized_query}%", "%#{sanitized_query}%")
    end
  rescue => e
    Rails.logger.error("Error in search_by_title_and_content: #{e.message}")
    # Return an empty scope if there's an error
    where(id: nil)
  end
  
  # Get top appearing articles in search results (global)
  def self.top_appearing(limit = 10)
    joins(:article_views)
      .select('articles.*, SUM(article_views.view_count) as total_appearances')
      .group('articles.id')
      .order('total_appearances DESC')
      .limit(limit)
  end
  
  # Get top appearing articles for a specific user with accurate per-user count
  def self.top_appearing_for_user(user_identifier, limit = 10)
    joins(:article_views)
      .joins(:search_queries)
      .where(search_queries: { user_identifier: user_identifier })
      .select('articles.*, SUM(article_views.view_count) as total_appearances')
      .group('articles.id')
      .order('total_appearances DESC')
      .limit(limit)
  end
  
  # Get appearance count for a specific user
  def appearance_count_for_user(user_identifier)
    # Get the count of unique search queries this article appeared in
    # rather than summing view_count which can be incremented multiple times
    article_views.joins(:search_query)
      .where(search_queries: { user_identifier: user_identifier })
      .count
  end
  
  # Increment the appearances count for this article
  def increment_appearances_count(user_identifier = nil)
    # Find the most recent search query for this user
    query_scope = SearchQuery.order(created_at: :desc)
    query_scope = query_scope.where(user_identifier: user_identifier) if user_identifier.present?
    
    last_query = query_scope.first
    
    if last_query.nil?
      puts "No search queries found in the database#{user_identifier ? ' for user ' + user_identifier : ''}"
      return
    end
    
    puts "Recording appearance for article #{id} (#{title}) with search query #{last_query.id} (#{last_query.term})"
    
    # Create or find the article view record
    begin
      # Only create a record if one doesn't exist yet for this search query
      article_view = ArticleView.find_or_initialize_by(
        article_id: id,
        search_query_id: last_query.id
      )
      
      # Only save if it's a new record; don't increment existing ones
      if article_view.new_record?
        article_view.view_count = 1
        saved = article_view.save
        puts "Created new article appearance: #{saved ? 'success' : 'failed'}"
        puts "Errors: #{article_view.errors.full_messages}" unless saved
      else
        puts "Article appearance already exists, not creating duplicate"
      end
    rescue => e
      puts "Error creating article appearance: #{e.class} - #{e.message}"
      puts e.backtrace.join("\n")
    end
  end
end
