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

      def save!
        before = document.to_h
        flow.edit_history.record(document.add(step), :added, [ step["id"] ], before)
      end

      private

      def document
        EasyFlow::Document.new(flow.document || flow.definition || {})
      end

      def step
        @step ||= { "id" => next_id, "type" => "question", "question" => question }
      end

      def next_id
        taken = document.nodes.map(&:id)
        (1..).lazy.map { |number| "question_#{number}" }.find { |id| !taken.include?(id) }
      end
    end
  end
end
