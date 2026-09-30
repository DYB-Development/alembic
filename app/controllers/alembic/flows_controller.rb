module Alembic
  class FlowsController < EasyFlow::FlowsController
    hosted_by FLOW_HOST
    include Summarizes
    helper_method :step_category

    private

    def step_category(question)
      EasyFlow::Steps::Question.category_of(@guide.step(question.id)&.config)
    end

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
