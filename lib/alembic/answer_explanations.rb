module Alembic
  module AnswerExplanations
    TEXT = {
      "question" => {
        "answers.weight" => "The points a player scores by picking this answer, and any weight above zero makes it a right answer."
      },
      "multiple_select" => {
        "answers.weight" => "Any weight above zero makes this a right answer, whatever its size, and the question scores one point only when a player ticks every right answer and no others."
      }
    }.freeze

    def explanation_for(step_type, setting)
      super || TEXT.dig(step_type.to_s, setting.to_s)
    end
  end
end
