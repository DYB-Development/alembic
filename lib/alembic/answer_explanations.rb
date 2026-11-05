module Alembic
  module AnswerExplanations
    TEXT = {
      "question" => {
        "answers.weight" => "The points a player scores by picking this answer, and any weight above zero makes it a right answer."
      }
    }.freeze

    def explanation_for(step_type, setting)
      TEXT.dig(step_type.to_s, setting.to_s)
    end
  end
end
