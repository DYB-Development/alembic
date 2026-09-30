module Alembic
  module Summarizes
    extend ActiveSupport::Concern

    included do
      layout -> { Alembic.layout }
      helper ApplicationHelper
      helper PagesHelper
      helper ResultBlocksHelper
      helper KsBlocks::LayoutHelper
      helper_method :flow_summary, :first_step_path, :summary_values
    end

    private

    def flow_summary(flow)
      Flow::Summaries.new(flow).text
    end

    def first_step_path(slug)
      flow_step_path(slug)
    end

    def start_run(flow)
      super.tap { |run| Flow::Summaries.new(flow).pin(run) }
    end

    def finished(answers, finished_run)
      @outputs = outputs_of(answers.transform_keys(&:to_s))
      Flow::Summaries.new(flow).pin(finished_run) if finished_run && run.nil?
      @summary_page = Flow::Summaries.new(run&.flow || flow).summary_page
      render template: @summary_page&.live_version ? "alembic/flows/summary_page" : "alembic/flows/complete"
    end

    def summary_values
      @outputs.to_h { |output| [ output.id, output.value ] }
        .merge("slug" => @guide.slug, "note" => result_note, "answers" => answers_given)
    end

    def answers_given
      @answered.map { |step, value| [ @guide.question_text(step), @guide.choice_label(step, value) ] }
    end

    def result_note
      finished_flow = run&.flow || flow
      [ finished_flow.title, *@outputs.map { |output| "#{output.label}: #{helpers.alembic_output_lines(output.value).join(', ')}" } ]
        .compact_blank.join(". ")
    end

    def outputs_of(state)
      return Flow::Summaries.new(run.flow).of_run(run, state) if run

      summaries = Flow::Summaries.new(flow)
      summaries.any? ? summaries.of(state) : []
    end
  end
end
