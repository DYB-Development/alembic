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

  def old_flow(slug = "old")
    connection.insert("INSERT INTO alembic_flows (slug, title, kind, created_at, updated_at) VALUES ('#{slug}', 'Old flow', 'guide', '2026-01-01', '2026-01-01')")
  end

  test "keeps each flow as a flow of easy_flow's under alembic's host" do
    migrated { old_flow }

    assert_equal [ [ "alembic", "Old flow", "guide" ] ], connection.select_rows("SELECT host, title, kind FROM easy_flow_definitions WHERE slug = 'old'")
  end

  def old_version(flow_id, number: 1, status: "live")
    connection.insert("INSERT INTO alembic_flow_versions (flow_id, number, definition, status, created_at) VALUES (#{flow_id}, #{number}, '{\"headline\":\"Hi\"}', '#{status}', '2026-01-01')")
  end

  test "keeps each flow's versions against its flow of easy_flow's" do
    migrated { old_version(old_flow) }

    assert_equal [ [ "old", 1, "live", "{\"headline\":\"Hi\"}" ] ],
      connection.select_rows("SELECT d.slug, v.number, v.status, v.definition FROM easy_flow_versions v JOIN easy_flow_definitions d ON d.id = v.flow_id WHERE d.slug = 'old'")
  end

  def old_run(flow_id, version_id, summary_version_id: "NULL")
    connection.insert("INSERT INTO alembic_flow_runs (flow_id, definition_version_id, summary_version_id, recorded, label, status, created_at, updated_at) VALUES (#{flow_id}, #{version_id}, #{summary_version_id}, '{\"budget\":\"low\"}', 'Acme', 'finished', '2026-01-01', '2026-01-01')")
  end

  test "keeps each run against its flow and version of easy_flow's" do
    migrated do
      flow = old_flow
      old_run(flow, old_version(flow))
    end

    assert_equal [ [ "old", 1, "{\"budget\":\"low\"}", "Acme", "finished" ] ],
      connection.select_rows("SELECT d.slug, v.number, r.recorded, r.label, r.status FROM easy_flow_runs r JOIN easy_flow_definitions d ON d.id = r.flow_id JOIN easy_flow_versions v ON v.id = r.definition_version_id WHERE d.slug = 'old'")
  end

  test "drops alembic's own flow tables" do
    migrated

    assert_empty %w[alembic_flows alembic_flow_versions alembic_flow_runs].select { |table| connection.table_exists?(table) }
  end

  test "points each summary version at a flow of easy_flow's" do
    migrated

    assert_equal({ "flow_id" => "easy_flow_definitions" }, referenced_by(:alembic_flow_summaries))
  end

  def old_summary_version(flow_id, number: 1)
    connection.insert("INSERT INTO alembic_flow_summaries (flow_id, number, summary, created_at) VALUES (#{flow_id}, #{number}, '{\"bands\":[]}', '2026-01-01')")
  end

  test "keeps each summary version against its flow of easy_flow's" do
    migrated { old_summary_version(old_flow) }

    assert_equal [ [ "old", 1, "{\"bands\":[]}" ] ],
      connection.select_rows("SELECT d.slug, s.number, s.summary FROM alembic_flow_summaries s JOIN easy_flow_definitions d ON d.id = s.flow_id")
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
