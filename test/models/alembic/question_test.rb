require "test_helper"

module Alembic
  class QuestionTest < ActiveSupport::TestCase
    setup { @category = Category.create!(name: "Rivers") }

    test "a multiple choice question with one option is refused with the reason" do
      question = @category.questions.choice_of(text: "Longest river?", labels: [ "Nile" ], right: 0)

      question.validate

      assert_includes question.errors.full_messages, "A multiple choice question needs at least two options"
    end

    test "a multiple choice question with no right option is refused with the reason" do
      question = @category.questions.choice_of(text: "Longest river?", labels: [ "Nile", "Amazon" ], right: nil)

      question.validate

      assert_includes question.errors.full_messages, "A question needs exactly one right option"
    end

    test "a multiple choice question with two right options is refused with the reason" do
      question = @category.questions.new(kind: :multiple_choice, text: "Longest river?",
        options: [ { "label" => "Nile", "right" => true }, { "label" => "Amazon", "right" => true } ])

      question.validate

      assert_includes question.errors.full_messages, "A question needs exactly one right option"
    end

    test "a multiple choice question leaves out options left blank" do
      question = @category.questions.choice_of(text: "Longest river?", labels: [ "Nile", "", "Amazon", " " ], right: 2)

      assert_equal [ { "label" => "Nile", "right" => false }, { "label" => "Amazon", "right" => true } ], question.options
    end
  end
end
