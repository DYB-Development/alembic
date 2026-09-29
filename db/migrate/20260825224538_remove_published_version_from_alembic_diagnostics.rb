class RemovePublishedVersionFromAlembicDiagnostics < ActiveRecord::Migration[8.1]
  class Diagnostic < ActiveRecord::Base
    self.table_name = "alembic_diagnostics"
  end

  class DefinitionVersion < ActiveRecord::Base
    self.table_name = "alembic_definition_versions"
  end

  def up
    [ Diagnostic, DefinitionVersion ].each(&:reset_column_information)
    DefinitionVersion.where(id: Diagnostic.where.not(published_version_id: nil).select(:published_version_id)).update_all(status: "live")

    remove_reference :alembic_diagnostics, :published_version, foreign_key: { to_table: :alembic_definition_versions }
  end

  def down
    add_reference :alembic_diagnostics, :published_version, foreign_key: { to_table: :alembic_definition_versions }

    [ Diagnostic, DefinitionVersion ].each(&:reset_column_information)
    DefinitionVersion.where(status: "live").find_each do |version|
      Diagnostic.where(id: version.diagnostic_id).update_all(published_version_id: version.id)
    end
  end
end
