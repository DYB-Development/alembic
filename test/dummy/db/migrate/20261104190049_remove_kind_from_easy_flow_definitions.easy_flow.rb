# This migration comes from easy_flow (originally 20261104184315)
class RemoveKindFromEasyFlowDefinitions < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    remove_column :easy_flow_definitions, :kind, if_exists: true
  end

  def down
    add_column :easy_flow_definitions, :kind, :string, if_not_exists: true
  end
end
