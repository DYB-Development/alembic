module Alembic
  module AnswerExplanations
    TEXT = {
      "question" => {
        "answers.info" => "Extra detail saved with this answer, which alembic's own question page does not show to a player.",
        "answers.hint" => "A smaller line a player sees under this answer's text.",
        "answers.label" => "The text a player sees for this answer in place of its value.",
        "answers.value" => "The text saved when a player picks this answer, which the player also sees when the label is blank or the flow shows answer values.",
        "answers.weight" => "The points a player scores by picking this answer, and any weight above zero makes it a right answer."
      },
      "multiple_select" => {
        "answers.label" => "The text a player sees for this answer in place of its value.",
        "answers.value" => "The text saved when a player ticks this answer, which the player also sees when the label is blank.",
        "answers.weight" => "Any weight above zero makes this a right answer, whatever its size, and the question scores one point only when a player ticks every right answer and no others."
      },
      "fill_in_the_blank" => {
        "accepted_answers.value" => "A typed answer that matches this text, ignoring capitals and the spaces around it, is right and scores one point."
      }
    }.freeze

    def explanation_for(step_type, setting)
      super || TEXT.dig(step_type.to_s, setting.to_s)
    end
  end
end
