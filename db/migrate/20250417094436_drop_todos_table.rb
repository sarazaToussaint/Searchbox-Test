class DropTodosTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :todos if table_exists?(:todos)
  end

  def down
    create_table :todos do |t|
      t.string :title, null: false
      t.boolean :completed, default: false

      t.timestamps
    end
  end
  
  private
  
  def table_exists?(table_name)
    ActiveRecord::Base.connection.table_exists?(table_name)
  end
end
