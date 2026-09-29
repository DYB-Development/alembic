class MoveFlowsOntoEasyFlow < ActiveRecord::Migration[8.1]
  HOST = "alembic"
  FLOW_COLUMNS = %w[slug title start_label kind status persists document definition_cursor
    changes_since_version undo_history undone_changes created_at updated_at].freeze

  class OldFlow < ActiveRecord::Base
    self.table_name = "alembic_flows"
  end

  class Definition < ActiveRecord::Base
    self.table_name = "easy_flow_definitions"
  end

  class OldVersion < ActiveRecord::Base
    self.table_name = "alembic_flow_versions"
  end

  class Version < ActiveRecord::Base
    self.table_name = "easy_flow_versions"
  end

  class OldRun < ActiveRecord::Base
    self.table_name = "alembic_flow_runs"
  end

  class Run < ActiveRecord::Base
    self.table_name = "easy_flow_runs"
  end

  def up
    [ OldFlow, Definition, OldVersion, Version, OldRun, Run ].each(&:reset_column_information)
    flows = copy_flows
    versions = copy_versions(flows)
    copy_runs(flows, versions)

    drop_table :alembic_flow_runs
    remove_foreign_key :alembic_flow_summaries, column: :flow_id
    execute "DELETE FROM alembic_flow_summaries"
    drop_table :alembic_flow_versions
    drop_table :alembic_flows
    add_foreign_key :alembic_flow_summaries, :easy_flow_definitions, column: :flow_id, on_delete: :cascade

    create_table :alembic_flow_definition_summaries do |t|
      t.references :flow, null: false, index: { unique: true },
        foreign_key: { to_table: :easy_flow_definitions, on_delete: :cascade }
      t.text :summary
      t.integer :summary_cursor
      t.timestamps
    end

    create_table :alembic_flow_run_summaries do |t|
      t.references :run, null: false, index: { unique: true },
        foreign_key: { to_table: :easy_flow_runs, on_delete: :cascade }
      t.references :summary_version, null: false,
        foreign_key: { to_table: :alembic_flow_summaries, on_delete: :cascade }
      t.timestamps
    end
  end

  def down
    drop_table :alembic_flow_run_summaries
    drop_table :alembic_flow_definition_summaries
    remove_foreign_key :alembic_flow_summaries, column: :flow_id
    execute "DELETE FROM alembic_flow_summaries"

    create_table :alembic_flows do |t|
      t.string :slug
      t.string :title
      t.text :summary
      t.string :start_label
      t.string :kind
      t.string :status, null: false, default: "active"
      t.string :persists, null: false, default: "unsaved"
      t.json :document
      t.integer :definition_cursor
      t.integer :summary_cursor
      t.json :changes_since_version
      t.json :undo_history
      t.json :undone_changes
      t.timestamps
    end
    add_index :alembic_flows, :slug, unique: true

    create_table :alembic_flow_versions do |t|
      t.references :flow, null: false, foreign_key: { to_table: :alembic_flows }
      t.integer :number, null: false
      t.json :definition
      t.json :changes_captured
      t.string :status, null: false, default: "draft"
      t.datetime :created_at, null: false
    end
    add_index :alembic_flow_versions, [ :flow_id, :number ], unique: true
    add_index :alembic_flow_versions, :flow_id, unique: true, where: "status = 'live'",
      name: "index_alembic_flow_versions_on_one_live_per_flow"

    add_foreign_key :alembic_flow_summaries, :alembic_flows, column: :flow_id

    create_table :alembic_flow_runs do |t|
      t.references :flow, null: false, foreign_key: { to_table: :alembic_flows }
      t.references :definition_version, null: false, foreign_key: { to_table: :alembic_flow_versions }
      t.references :summary_version, foreign_key: { to_table: :alembic_flow_summaries }
      t.references :owner, polymorphic: true
      t.json :recorded
      t.string :label
      t.string :status
      t.timestamps
    end
  end

  private

  def copy_flows
    OldFlow.order(:id).to_h do |flow|
      [ flow.id, Definition.create!(flow.attributes.slice(*FLOW_COLUMNS).merge("host" => HOST)).id ]
    end
  end

  def copy_versions(flows)
    OldVersion.order(:id).to_h do |version|
      copied = version.attributes.slice("number", "definition", "changes_captured", "status", "created_at")
      [ version.id, Version.create!(copied.merge("flow_id" => flows.fetch(version.flow_id))).id ]
    end
  end

  def copy_runs(flows, versions)
    OldRun.order(:id).to_h do |run|
      copied = run.attributes.slice("owner_type", "owner_id", "recorded", "label", "status", "created_at", "updated_at")
      moved = copied.merge("flow_id" => flows.fetch(run.flow_id), "definition_version_id" => versions.fetch(run.definition_version_id))
      [ run.id, Run.create!(moved).id ]
    end
  end
end
