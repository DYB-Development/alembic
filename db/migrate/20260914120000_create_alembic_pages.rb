class CreateAlembicPages < ActiveRecord::Migration[8.1]
  def change
    create_table :alembic_pages do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
