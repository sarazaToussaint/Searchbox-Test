class FixSearchQueriesIndex < ActiveRecord::Migration[8.0]
  def change
    # Remove the existing unique index on term
    remove_index :search_queries, :term
    
    # Add a new index on term (non-unique)
    add_index :search_queries, :term, unique: false
    
    # Add a compound unique index for term, user_identifier, and ip_address
    add_index :search_queries, [:term, :user_identifier, :ip_address], unique: true, name: 'index_search_queries_on_term_user_ip'
  end
end
