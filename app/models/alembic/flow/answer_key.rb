module Alembic
  module Flow
    module AnswerKey
      def self.chosen(step)
        Outputs::WeightedSum.right_answers(step).first
      end
    end
  end
end
