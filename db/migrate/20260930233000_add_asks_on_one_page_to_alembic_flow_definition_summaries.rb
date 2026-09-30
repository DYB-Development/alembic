class AddAsksOnOnePageToAlembicFlowDefinitionSummaries < ActiveRecord::Migration[8.1]
  def change
    add_column :alembic_flow_definition_summaries, :asks_on_one_page, :boolean, default: false, null: false
  end
end
