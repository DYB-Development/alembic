module Alembic
  module Flow
    class DefinitionSummary < ApplicationRecord
      self.table_name = "alembic_flow_definition_summaries"

      belongs_to :flow, class_name: "EasyFlow::Definition"
      belongs_to :summary_page, class_name: "Alembic::Page", optional: true
      belongs_to :intro_page, class_name: "Alembic::Page", optional: true
    end
  end
end
