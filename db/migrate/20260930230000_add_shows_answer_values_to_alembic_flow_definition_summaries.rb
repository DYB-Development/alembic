class AddShowsAnswerValuesToAlembicFlowDefinitionSummaries < ActiveRecord::Migration[8.1]
  def change
    add_column :alembic_flow_definition_summaries, :shows_answer_values, :boolean, default: false, null: false
  end
end
