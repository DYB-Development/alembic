module Alembic
  module Flow
    class Summaries
      def initialize(flow)
        @flow = flow
      end

      def document
        current_version&.summary
      end

      def current_version
        versions.find_by(number: cursor)
      end

      def record(payload)
        Array(payload.to_h["outputs"]).each { |output| Summary.registry.fetch(output["type"]) if output["type"].present? }
        versions.create!(number: next_number, summary: payload)
          .tap { |version| details.update!(summary_cursor: version.number) }
      end

      def any?
        document.present?
      end

      def of(state)
        Summary::Report.new(document).results(Summary::Run.new(state: state, steps: steps_by_id))
      end

      def text
        details.summary
      end

      def describe(text)
        details.update!(summary: text)
      end

      def summary_page
        details.summary_page
      end

      def shows_answer_values?
        details.shows_answer_values
      end

      def show_answer_values(shown)
        details.update!(shows_answer_values: shown)
      end

      def asks_on_one_page?
        details.asks_on_one_page
      end

      def ask_on_one_page(asked)
        details.update!(asks_on_one_page: asked && !branches?)
      end

      def branches?
        Array(@flow.definition.to_h["nodes"]).any? do |node|
          EasyFlow.registry.registered?(node["type"]) && EasyFlow.registry.fetch(node["type"]).routes?
        end
      end

      def intro_page
        details.intro_page
      end

      def start_on(page)
        details.update!(intro_page: page)
      end

      def finish_on(page)
        details.update!(summary_page: page)
      end

      def pin(run)
        RunSummary.create!(run: run, summary_version: current_version) if current_version
      end

      def pinned_to(run)
        RunSummary.find_by(run: run)&.summary_version
      end

      def of_run(run, state)
        pinned = pinned_to(run)&.summary
        return [] if pinned.blank?

        Summary::Report.new(pinned).results(Summary::Run.new(state: state, steps: run.pinned_steps))
      end

      private

      def versions
        SummaryVersion.where(flow: @flow)
      end

      def details
        @details ||= DefinitionSummary.find_or_initialize_by(flow: @flow)
      end

      def steps_by_id
        Array(@flow.definition.to_h["nodes"]).index_by { |node| node["id"] }
      end

      def cursor
        details.summary_cursor || versions.maximum(:number)
      end

      def next_number
        (versions.maximum(:number) || 0) + 1
      end
    end
  end
end
