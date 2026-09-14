class SeedDocumentsFromCurrentDefinitions < ActiveRecord::Migration[8.1]
  class Diagnostic < ActiveRecord::Base
    self.table_name = "alembic_diagnostics"
  end

  class DefinitionVersion < ActiveRecord::Base
    self.table_name = "alembic_definition_versions"
  end

  def up
    Diagnostic.find_each do |diagnostic|
      definition = current_definition(diagnostic)
      next if definition.blank?

      diagnostic.update_columns(document: definition)
    end
  end

  def down
    Diagnostic.update_all(document: nil)
  end

  private

  def current_definition(diagnostic)
    versions = DefinitionVersion.where(diagnostic_id: diagnostic.id)
    versions.find_by(number: diagnostic.definition_cursor || versions.maximum(:number))&.definition
  end
end
