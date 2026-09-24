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
