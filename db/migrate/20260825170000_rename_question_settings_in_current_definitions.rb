class RenameQuestionSettingsInCurrentDefinitions < ActiveRecord::Migration[8.1]
  RENAMED = { "text" => "question", "options" => "answers", "tag" => "category" }.freeze

  class Diagnostic < ActiveRecord::Base
    self.table_name = "alembic_diagnostics"
  end

  class DefinitionVersion < ActiveRecord::Base
    self.table_name = "alembic_definition_versions"
  end

  def up
    Diagnostic.find_each do |diagnostic|
      definition = current_definition(diagnostic)
      renamed = rename(definition)
      next if renamed.nil? || renamed == definition

      record_definition(diagnostic, renamed)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      "definition versions are append-only; step back the diagnostic's cursor to undo this"
  end

  private

  def current_definition(diagnostic)
    versions = DefinitionVersion.where(diagnostic_id: diagnostic.id)
    versions.find_by(number: diagnostic.definition_cursor || versions.maximum(:number))&.definition
  end

  def record_definition(diagnostic, definition)
    number = (DefinitionVersion.where(diagnostic_id: diagnostic.id).maximum(:number) || 0) + 1
    DefinitionVersion.create!(diagnostic_id: diagnostic.id, number: number, definition: definition)
    diagnostic.update!(definition_cursor: number)
  end

  def rename(definition)
    return if definition.blank?

    definition.merge("nodes" => Array(definition["nodes"]).map { |node| rename_node(node) })
  end

  def rename_node(node)
    return node unless node["type"] == "question"

    node.to_h { |key, value| [ RENAMED.fetch(key, key), value ] }
  end
end
