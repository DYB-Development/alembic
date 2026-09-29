require "test_helper"
require Rails.root.join("../../db/migrate/20260825224538_remove_published_version_from_alembic_diagnostics.rb")

class RemovePublishedVersionFromAlembicDiagnosticsTest < ActiveSupport::TestCase
  def connection
    ActiveRecord::Base.connection
  end

  def with_diagnostic_tables
    connection.create_table(:alembic_diagnostics) { |t| t.string :slug }
    connection.create_table(:alembic_definition_versions) do |t|
      t.references :diagnostic, null: false
      t.integer :number, null: false
      t.string :status, null: false, default: "draft"
    end
    connection.add_reference :alembic_diagnostics, :published_version, foreign_key: { to_table: :alembic_definition_versions }
    yield
  end

  test "marks the version a diagnostic had published as its live version" do
    ActiveRecord::Migration.suppress_messages do
      with_diagnostic_tables do
        diagnostic = connection.insert("INSERT INTO alembic_diagnostics (slug) VALUES ('ladder')")
        connection.insert("INSERT INTO alembic_definition_versions (diagnostic_id, number) VALUES (#{diagnostic}, 1)")
        published = connection.insert("INSERT INTO alembic_definition_versions (diagnostic_id, number) VALUES (#{diagnostic}, 2)")
        connection.update("UPDATE alembic_diagnostics SET published_version_id = #{published}")

        RemovePublishedVersionFromAlembicDiagnostics.new.migrate(:up)
      end
    end

    assert_equal [ [ 1, "draft" ], [ 2, "live" ] ], connection.select_rows("SELECT number, status FROM alembic_definition_versions ORDER BY number")
  end
end
