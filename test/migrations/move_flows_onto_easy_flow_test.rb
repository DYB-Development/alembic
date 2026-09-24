require "test_helper"
require Rails.root.join("../../db/migrate/20260924220000_move_flows_onto_easy_flow.rb")

class MoveFlowsOntoEasyFlowTest < ActiveSupport::TestCase
  def migrated
    migration = MoveFlowsOntoEasyFlow.new
    ActiveRecord::Migration.suppress_messages do
      migration.down
      yield if block_given?
      migration.up
    end
  end

  def connection
    ActiveRecord::Base.connection
  end

  def referenced_by(table)
    connection.foreign_keys(table).to_h { |key| [ key.column, key.to_table ] }
  end

  test "drops alembic's own flow tables" do
    migrated

    assert_empty %w[alembic_flows alembic_flow_versions alembic_flow_runs].select { |table| connection.table_exists?(table) }
  end

  test "points each summary version at a flow of easy_flow's" do
    migrated

    assert_equal({ "flow_id" => "easy_flow_definitions" }, referenced_by(:alembic_flow_summaries))
  end

  test "clears the summary versions of the flows it drops" do
    migrated do
      flow_id = connection.insert("INSERT INTO alembic_flows (slug, created_at, updated_at) VALUES ('old', '2026-01-01', '2026-01-01')")
      connection.insert("INSERT INTO alembic_flow_summaries (flow_id, number, created_at) VALUES (#{flow_id}, 1, '2026-01-01')")
    end

    assert_equal 0, connection.select_value("SELECT COUNT(*) FROM alembic_flow_summaries")
  end

  test "keeps a flow's summary text and summary cursor against a flow of easy_flow's" do
    migrated

    assert_equal({ "flow_id" => "easy_flow_definitions" }, referenced_by(:alembic_flow_definition_summaries))
  end

  test "keeps the summary version a run is pinned to against a run of easy_flow's" do
    migrated

    assert_equal({ "run_id" => "easy_flow_runs", "summary_version_id" => "alembic_flow_summaries" },
      referenced_by(:alembic_flow_run_summaries))
  end

  test "going back restores alembic's own flow tables" do
    ActiveRecord::Migration.suppress_messages { MoveFlowsOntoEasyFlow.new.down }

    assert_equal({ "flow_id" => "alembic_flows" }, referenced_by(:alembic_flow_summaries))
  end
end
