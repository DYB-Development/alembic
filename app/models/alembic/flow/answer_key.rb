module Alembic
  module Flow
    module AnswerKey
      def self.chosen(step)
        right = Outputs::WeightedSum.right_answers(step)
        step["type"] == "multiple_select" ? right : right.first
      end
    end
  end
end
