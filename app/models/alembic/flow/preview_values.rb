module Alembic
  module Flow
    module PreviewValues
      def self.values(page, _choice)
        flow = flow_for(page)
        return {} if flow.nil?

        Summaries.new(flow).of(sample_state(flow)).to_h { |result| [ result.id, result.value ] }
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

      private_class_method :flow_for, :sample_state
    end
  end
end
