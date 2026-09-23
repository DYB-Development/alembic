class AddSlugToAlembicPages < ActiveRecord::Migration[8.1]
  def change
    add_column :alembic_pages, :slug, :string
    add_index :alembic_pages, :slug, unique: true
  end
end
