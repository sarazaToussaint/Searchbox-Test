class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :author
      t.string :category

      t.timestamps
    end
    
    add_index :articles, :title
    add_index :articles, :category
  end
end
