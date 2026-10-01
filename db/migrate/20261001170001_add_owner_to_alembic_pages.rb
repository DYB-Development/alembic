class AddOwnerToAlembicPages < ActiveRecord::Migration[8.1]
  def change
    add_reference :alembic_pages, :owner, polymorphic: true, index: false
    remove_index :alembic_pages, :slug, unique: true
    add_index :alembic_pages, :slug, unique: true, where: "owner_id IS NULL", name: "index_alembic_pages_on_slug"
    add_index :alembic_pages, [ :owner_type, :owner_id, :slug ], unique: true, where: "owner_id IS NOT NULL",
      name: "index_alembic_pages_on_owner_and_slug"
  end
end
