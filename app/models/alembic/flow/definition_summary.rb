module Alembic
  module Flow
    class DefinitionSummary < ApplicationRecord
      self.table_name = "alembic_flow_definition_summaries"

      belongs_to :flow, class_name: "EasyFlow::Definition"
    end
  end
end
