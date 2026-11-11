module Alembic
  module Flow
    module AnswerKey
      def self.chosen(step)
        QuestionKit::AnswerKey.chosen(step)
      end

      def self.accepted(step)
        QuestionKit::AnswerKey.accepted(step)
      end
    end
  end
end
