module Alembic
  class QuestionImporter < Ixport::Importer
    field :type, label: "Type"
    field :question, label: "Question"
    field :category, label: "Category"
    Flow::UploadedQuestion::ANSWER_FIELDS.each.with_index(1) { |key, number| field key, label: "Answer #{number}" }
    field :right_answer, label: "Right answer"

    def records
      Flow::UploadedQuestions.new(target)
    end

    def self.allows?(account, quiz)
      quiz.is_a?(EasyFlow::Definition) && quiz.host == FLOW_HOST.to_s && (Alembic.owner_method.nil? || quiz.owner == account)
    end
  end
end
