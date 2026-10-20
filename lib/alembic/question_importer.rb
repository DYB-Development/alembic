module Alembic
  class QuestionImporter < Ixport::Importer
    field :type, label: "Type"
    field :question, label: "Question"
    field :category, label: "Category"
    Flow::UploadedQuestion::ANSWER_FIELDS.each.with_index(1) { |key, number| field key, label: "Answer #{number}" }
    field :right_answer, label: "Right answer"
  end
end
