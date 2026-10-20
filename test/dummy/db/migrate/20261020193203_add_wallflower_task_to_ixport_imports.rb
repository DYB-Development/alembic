class AddWallflowerTaskToIxportImports < ActiveRecord::Migration[8.1]
  def change
    add_column :ixport_imports, :wallflower_task_id, :bigint
    add_index :ixport_imports, :wallflower_task_id
  end
end
