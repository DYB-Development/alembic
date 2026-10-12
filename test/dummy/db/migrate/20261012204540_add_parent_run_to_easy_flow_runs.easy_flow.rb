# This migration comes from easy_flow (originally 20261007120000)
class AddParentRunToEasyFlowRuns < ActiveRecord::Migration[8.1]
  def change
    add_reference :easy_flow_runs, :parent_run, foreign_key: { to_table: :easy_flow_runs }
    add_column :easy_flow_runs, :parent_step, :string
  end
end
