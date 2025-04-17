class AddUserTrackingToSearchQueries < ActiveRecord::Migration[7.0]
  def change
    add_column :search_queries, :user_identifier, :string
    add_column :search_queries, :ip_address, :string
    
    add_index :search_queries, :user_identifier
    add_index :search_queries, :ip_address
  end
end 