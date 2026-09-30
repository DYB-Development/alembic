module Alembic
  class FlowsController < EasyFlow::FlowsController
    hosted_by FLOW_HOST
    include Summarizes
    helper_method :step_category, :shows_answer_values?

    def step
      return super unless asked_on_one_page?

      @guide = runner_for(running_definition)
      @questions = questions_in_order
      render :one_page
    end

    private

    def asked_on_one_page?
      run.nil? && params[:answers].blank? && Flow::Summaries.new(flow).asks_on_one_page?
    end

    def questions_in_order
      state = {}
      questions = []
      while (question = @guide.next_step(state))
        questions << question
        state[question.id.to_s] = "asked"
      end
      questions
    end

    def shows_answer_values?
      Flow::Summaries.new(run&.flow || flow).shows_answer_values?
    end

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
