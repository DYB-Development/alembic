require "test_helper"

module Alembic
  class QuestionTest < ActiveSupport::TestCase
    setup { @category = Category.create!(name: "Rivers") }

    test "a multiple choice question with one option is refused with the reason" do
      question = @category.questions.choice_of(text: "Longest river?", labels: [ "Nile" ], right: 0)

      question.validate

      assert_includes question.errors.full_messages, "A multiple choice question needs at least two options"
    end
  end
end
