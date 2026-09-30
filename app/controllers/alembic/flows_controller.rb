module Alembic
  class FlowsController < EasyFlow::FlowsController
    hosted_by FLOW_HOST
    include Summarizes
    helper_method :step_category, :shows_answer_values?, :intro_values

    def step
      return super unless asked_on_one_page?

      @guide = runner_for(running_definition)
      @questions = questions_in_order
      render :one_page
    end

    private

    def intro_values
      starts_a_run = @flow.each_step? && !previewing?
      { "title" => @flow.title.presence || @flow.slug, "summary" => flow_summary(@flow),
        "question_count" => question_count, "starts_a_run" => starts_a_run,
        "start_path" => starts_a_run ? alembic.flow_runs_path(@flow.slug) : first_step_path(@flow.slug) }
    end

    def question_count
      Array(@flow.live_definition.to_h["nodes"]).count { |node| node["type"] == "question" }
    end

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
