require "test_helper"

module Alembic
  class QuestionBuilderTest < ActionDispatch::IntegrationTest
    setup { @category = Category.create!(name: "Rivers") }

    test "adding a true/false question marks the answer the builder chose as right" do
      post alembic.manage_category_questions_path(@category),
        params: { question: { kind: "true_false", text: "The Nile flows north.", right: "True" } }

      assert_equal [ { "label" => "True", "right" => true }, { "label" => "False", "right" => false } ], @category.questions.sole.options
    end
  end
end
