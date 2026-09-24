module Alembic
  module Summarizes
    extend ActiveSupport::Concern

    included do
      layout -> { Alembic.layout }
      helper ApplicationHelper
    end

    private

    def start_run(flow)
      super.tap { |run| Flow::Summaries.new(flow).pin(run) }
    end

    def finished(answers, finished_run)
      @outputs = outputs_of(answers.transform_keys(&:to_s))
      Flow::Summaries.new(flow).pin(finished_run) if finished_run && run.nil?
      render template: "alembic/flows/complete"
    end

    def outputs_of(state)
      return Flow::Summaries.new(run.flow).of_run(run, state) if run

      summaries = Flow::Summaries.new(flow)
      summaries.any? ? summaries.of(state) : []
    end
  end
end
