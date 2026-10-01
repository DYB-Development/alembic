module Alembic
  module Flow
    module PreviewValues
      def self.values(page, choice)
        flow = flow_for(page)
        return {} if flow.nil?

        summaries = Summaries.new(flow)
        state = finished_runs(flow).find { |run| run.id.to_s == choice.to_s }&.recorded || sample_state(flow)
        introduced(flow, summaries).merge(summaries.of(state).to_h { |result| [ result.id, result.value ] })
      end

      def self.finished_runs(flow)
        EasyFlow::Run.where(flow: flow).order(created_at: :desc).limit(20).select { |run| run.next_step(run.recorded).nil? }
      end

      def self.introduced(flow, summaries)
        questions = Array(flow.live_definition.to_h["nodes"]).count { |node| node["type"] == "question" }
        { "title" => flow.title.presence || flow.slug, "summary" => summaries.text, "question_count" => questions,
          "slug" => flow.slug, "start_path" => "#", "starts_a_run" => false }
      end

      def self.choices(page)
        flow = flow_for(page)
        return [] if flow.nil?

        finished_runs(flow).map { |run| [ "Run of #{I18n.l(run.created_at, format: :short)}", run.id.to_s ] }
      end

      def self.flow_for(page)
        DefinitionSummary.where(summary_page: page).or(DefinitionSummary.where(intro_page: page)).first&.flow
      end

      def self.sample_state(flow)
        questions = Array(flow.live_definition.to_h["nodes"]).select { |node| node["type"] == "question" }
        questions.each_with_index.filter_map do |question, index|
          answers = EasyFlow::Steps::Question.answers_of(question)
          next if answers.empty?

          [ question["id"], answers[index % answers.size].then { |answer| answer.is_a?(Hash) ? answer["value"] : answer } ]
        end.to_h
      end

      private_class_method :flow_for, :introduced, :finished_runs
    end
  end
end
