module Alembic
  module Flow
    module AnswerKey
      def self.chosen(step)
        case step["type"]
        when "multiple_select" then Outputs::WeightedSum.right_answers(step)
        when "fill_in_the_blank" then Array(step["accepted_answers"]).first&.fetch("value", nil)
        else Outputs::WeightedSum.right_answers(step).first
        end
      end
    end
  end
end
