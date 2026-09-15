class AddBlocksToAlembicPages < ActiveRecord::Migration[8.1]
  def change
    add_column :alembic_pages, :blocks, :json, default: [], null: false
  end
end
