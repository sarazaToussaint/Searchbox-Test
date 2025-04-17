class ArticleView < ApplicationRecord
  belongs_to :article
  belongs_to :search_query
  
  validates :article_id, presence: true
  validates :search_query_id, presence: true
  validates :article_id, uniqueness: { scope: :search_query_id }
  
  # Increment the appearance count
  def increment_appearances
    increment!(:view_count)
  end
  
  # Find or create an article appearance
  def self.record_appearance(article_id, search_query_id)
    # Only create a record if one doesn't exist yet, never increment
    find_or_create_by(
      article_id: article_id,
      search_query_id: search_query_id,
      view_count: 1
    )
  end
end
