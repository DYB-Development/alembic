class AddKeptResultToAlembicFlowRunSummaries < ActiveRecord::Migration[8.1]
  def change
    add_column :alembic_flow_run_summaries, :score, :integer
    add_column :alembic_flow_run_summaries, :seconds_taken, :integer
  end
end
