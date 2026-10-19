class CreateAlembicQuestionsInCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :alembic_questions do |t|
      t.references :category, null: false, foreign_key: { to_table: :alembic_categories }
      t.string :kind, null: false
      t.string :text, null: false
      t.json :options, default: [], null: false

      t.timestamps
    end
  end
end
