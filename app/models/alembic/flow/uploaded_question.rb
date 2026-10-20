module Alembic
  module Flow
    class UploadedQuestion
      include ActiveModel::Model
      include ActiveModel::Attributes

      attr_accessor :flow

      attribute :type, :string
      attribute :question, :string
      attribute :category, :string
      attribute :right_answer, :string
      ANSWER_FIELDS = (1..6).map { |number| :"answer_#{number}" }
      ANSWER_FIELDS.each { |field| attribute field, :string }

      validates :question, presence: true

      def save!
        before = document.to_h
        flow.edit_history.record(appended, :added, [ step["id"] ], before)
      end

      private

      def document
        EasyFlow::Document.new(flow.document || flow.definition || {})
      end

      def appended
        leaving = document.edges_from(last_question).first
        return document.insert(step, on: [ last_question, leaving.to ]) if leaving

        document.add(step).connect(from: last_question, to: step["id"])
      end

      def last_question
        reached = document.reachable
        reached.reverse.find { |id| document.node(id)&.type == "question" } || reached.last
      end

      def step
        @step ||= { "id" => next_id, "type" => "question", "question" => question, "category" => category.presence, "answers" => answers }.compact
      end

      def answers
        return true_false_answers if kind == "truefalse"

        filled_answers.map { |number, text| { "value" => text, "weight" => number.to_s == right_answer.to_s.strip ? 1 : 0 } }
      end

      def true_false_answers
        %w[True False].map { |text| { "value" => text, "weight" => text.casecmp?(right_answer.to_s.strip) ? 1 : 0 } }
      end

      def kind
        type.to_s.downcase.gsub(/[^a-z]/, "")
      end

      def filled_answers
        ANSWER_FIELDS.each_with_index.filter_map { |field, index| [ index + 1, public_send(field).strip ] if public_send(field).present? }
      end

      def next_id
        taken = document.nodes.map(&:id)
        (1..).lazy.map { |number| "question_#{number}" }.find { |id| !taken.include?(id) }
      end
    end
  end
end
