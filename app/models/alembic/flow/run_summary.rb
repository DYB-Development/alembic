module Alembic
  module Flow
    class RunSummary < ApplicationRecord
      self.table_name = "alembic_flow_run_summaries"

      belongs_to :run, class_name: "EasyFlow::Run"
      belongs_to :summary_version
    end
  end
end
