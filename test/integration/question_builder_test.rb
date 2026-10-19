require "test_helper"

module Alembic
  class QuestionBuilderTest < ActionDispatch::IntegrationTest
    setup { @category = Category.create!(name: "Rivers") }

    test "adding a true/false question marks the answer the builder chose as right" do
      post alembic.manage_category_questions_path(@category),
        params: { question: { kind: "true_false", text: "The Nile flows north.", right: "True" } }

      assert_equal [ { "label" => "True", "right" => true }, { "label" => "False", "right" => false } ], @category.questions.sole.options
    end

    test "adding a multiple choice question marks the option the builder chose as right" do
      post alembic.manage_category_questions_path(@category),
        params: { question: { kind: "multiple_choice", text: "Longest river?", labels: [ "Amazon", "Nile", "" ], right: "1" } }

      assert_equal [ { "label" => "Amazon", "right" => false }, { "label" => "Nile", "right" => true } ], @category.questions.sole.options
    end
  end
end
