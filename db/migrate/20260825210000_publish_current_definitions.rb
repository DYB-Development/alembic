class PublishCurrentDefinitions < ActiveRecord::Migration[8.1]
  class Diagnostic < ActiveRecord::Base
    self.table_name = "alembic_diagnostics"
  end

  class DefinitionVersion < ActiveRecord::Base
    self.table_name = "alembic_definition_versions"
  end

  def up
    Diagnostic.find_each do |diagnostic|
      current = current_definition_version(diagnostic)
      next if current.nil?

      diagnostic.update_columns(published_version_id: current.id, status: "published")
    end
  end

  def down
    Diagnostic.update_all(published_version_id: nil)
  end

  private

  def current_definition_version(diagnostic)
    versions = DefinitionVersion.where(diagnostic_id: diagnostic.id)
    versions.find_by(number: diagnostic.definition_cursor || versions.maximum(:number))
  end
end
