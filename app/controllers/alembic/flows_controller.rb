module Alembic
  class FlowsController < EasyFlow::FlowsController
    include Summarizes

    private

    def run_location(run)
      alembic.run_path(run)
    end

    def flow_start_path(slug)
      alembic.flow_path(slug)
    end

    def flow_step_path(slug)
      alembic.flow_step_path(slug)
    end
  end
end
