class AddSearchCountToSearchQueries < ActiveRecord::Migration[8.0]
  def change
    add_column :search_queries, :search_count, :integer, default: 0, null: false
  end
end
