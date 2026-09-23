class CreateAlembicPageVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :alembic_page_versions do |t|
      t.references :page, null: false, foreign_key: { to_table: :alembic_pages }
      t.integer :number, null: false
      t.json :blocks, default: [], null: false
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

    add_index :alembic_page_versions, [ :page_id, :number ], unique: true
    add_index :alembic_page_versions, :page_id, unique: true, where: "status = 'live'",
      name: "index_alembic_page_versions_on_one_live_per_page"
  end
end
