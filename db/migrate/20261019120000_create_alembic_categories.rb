class CreateAlembicCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :alembic_categories do |t|
      t.string :name, null: false
      t.references :owner, polymorphic: true

      t.timestamps
    end
  end
end
