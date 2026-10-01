class AddIntroPageToAlembicFlowDefinitionSummaries < ActiveRecord::Migration[8.1]
  def change
    add_reference :alembic_flow_definition_summaries, :intro_page,
      foreign_key: { to_table: :alembic_pages, on_delete: :nullify }
  end
end
