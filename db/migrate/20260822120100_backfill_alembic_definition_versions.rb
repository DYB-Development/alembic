class BackfillAlembicDefinitionVersions < ActiveRecord::Migration[8.1]
  class Diagnostic < ActiveRecord::Base
    self.table_name = "alembic_diagnostics"
  end

  class DefinitionVersion < ActiveRecord::Base
    self.table_name = "alembic_definition_versions"
  end

  def up
    Diagnostic.where.not(definition: nil).find_each do |diagnostic|
      next if DefinitionVersion.exists?(diagnostic_id: diagnostic.id)

      DefinitionVersion.create!(diagnostic_id: diagnostic.id, number: 1, definition: diagnostic.definition)
    end
  end
end
