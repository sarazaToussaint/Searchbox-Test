class CreateSearchQueries < ActiveRecord::Migration[7.1]
  def change
    create_table :search_queries do |t|
      t.string :term, null: false
      t.integer :results_count, default: 0
      t.datetime :last_searched_at
      t.string :user_identifier, null: false
      t.string :ip_address, null: false
      
      t.timestamps
    end
    
    add_index :search_queries, [:term, :user_identifier, :ip_address], unique: true, name: 'idx_search_queries_on_term_user_ip'
  end
end
