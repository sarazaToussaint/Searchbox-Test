class SearchQuery < ApplicationRecord
  has_many :article_views, dependent: :destroy
  has_many :articles, through: :article_views
  
  validates :term, presence: true
  validates :user_identifier, presence: true
  validates :ip_address, presence: true
  
  # Remove uniqueness constraint on term alone
  # Instead make it unique per user/ip combination
  validates :term, uniqueness: { scope: [:user_identifier, :ip_address] }
  
  # Remove scope related to is_complete field since it was removed
  # scope :complete, -> { where(is_complete: true) }
  scope :for_user, ->(user_id) { where(user_identifier: user_id) }
  scope :from_ip, ->(ip) { where(ip_address: ip) }
  scope :by_popularity, -> { 
    left_joins(:article_views)
    .group(:id)
    .order('COUNT(article_views.id) DESC') 
  }
  
  # Find or initialize a search query by term
  def self.find_or_initialize_by_term(term)
    find_or_initialize_by(term: term)
  end
  
  # Find or create a search query with user context
  def self.find_or_initialize_by_term_and_user(term, user_identifier:, ip_address:)
    # Normalize the term to avoid duplicates
    normalized_term = term.to_s.strip
    
    # Find or initialize the search query
    search_query = find_or_initialize_by(
      term: normalized_term,
      user_identifier: user_identifier,
      ip_address: ip_address
    )
    
    # Initialize count if new record
    search_query.search_count ||= 0
    search_query.search_count += 1
    
    search_query
  end
  
  # Update the record with search results
  def record_search(results_count)
    self.results_count = results_count
    self.last_searched_at = Time.current
    save
  end
  
  # Analytics methods for getting top searches
  def self.top_searches_for_user(user_id, limit = 10)
    for_user(user_id).order(search_count: :desc).limit(limit)
  end
  
  def self.top_searches_from_ip(ip, limit = 10)
    from_ip(ip).order(search_count: :desc).limit(limit)
  end
  
  # Get globally popular searches
  def self.globally_popular(limit = 10)
    joins(:article_views)
      .select('search_queries.*, COUNT(article_views.id) as popularity')
      .group('search_queries.id')
      .order('popularity DESC')
      .limit(limit)
  end
  
  # Get top searches globally
  def self.top_searches(limit = 5)
    select('term, SUM(search_count) as total_searches')
      .group('term')
      .order('total_searches DESC')
      .limit(limit)
  rescue => e
    Rails.logger.error("Error in top_searches: #{e.message}")
    []
  end
  
  # Get top searches for a specific user
  def self.top_searches_for_user(user_identifier, limit = 5)
    Rails.logger.info "Finding top searches for user: #{user_identifier}"
    
    # Get all searches for this user
    searches = where(user_identifier: user_identifier).order(search_count: :desc).limit(limit)
    
    # Debug output
    if searches.empty?
      Rails.logger.info "No searches found for user #{user_identifier}"
    else
      Rails.logger.info "Found #{searches.count} searches for user #{user_identifier}"
      searches.each do |search|
        Rails.logger.info "  - #{search.term} (#{search.search_count} times, #{search.results_count} results)"
      end
    end
    
    return searches
  rescue => e
    Rails.logger.error("Error in top_searches_for_user: #{e.message}")
    []
  end
  
  # Get top search terms (just the strings) for a specific user
  def self.top_search_terms_for_user(user_identifier, limit = 5)
    where(user_identifier: user_identifier)
      .order(search_count: :desc)
      .limit(limit)
      .pluck(:term)
  rescue => e
    Rails.logger.error("Error in top_search_terms_for_user: #{e.message}")
    []
  end
  
  # Delete similar searches to keep analytics clean - PostgreSQL safe version
  def delete_similar_searches
    # Delete searches that might be typing intermediates
    # For example, if "ruby programming" exists, 
    # delete "rub", "ruby", "ruby p", etc. to keep analytics clean
    return if term.blank?
    
    begin
      # Use LIKE for SQLite and ILIKE for PostgreSQL (case-insensitive)
      if self.class.connection.adapter_name.downcase.include?('postgresql')
        SearchQuery.where(user_identifier: user_identifier)
                  .where("term ILIKE ? AND term != ? AND id != ?", 
                         "#{term.first(term.length/2)}%", 
                         term, 
                         id)
                  .destroy_all
      else
        SearchQuery.where(user_identifier: user_identifier)
                  .where("term LIKE ? AND term != ? AND id != ?", 
                         "#{term.first(term.length/2)}%", 
                         term, 
                         id)
                  .destroy_all
      end
    rescue => e
      Rails.logger.error("Error in delete_similar_searches: #{e.message}")
    end
  end
  
  private
  
  def user_identifier?
    user_identifier.present?
  end
end
