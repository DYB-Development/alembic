class AddShufflesAnswersToAlembicFlowDefinitionSummaries < ActiveRecord::Migration[8.1]
  def change
    add_column :alembic_flow_definition_summaries, :shuffles_answers, :boolean, default: false, null: false
  end
end
