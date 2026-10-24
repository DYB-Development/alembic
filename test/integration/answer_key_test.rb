require "test_helper"

module Alembic
  class AnswerKeyTest < ActionDispatch::IntegrationTest
    def quiz
      @quiz ||= EasyFlow::Definition.create!(host: "alembic", slug: "quiz").tap do |flow|
        flow.edit_history.edit_document(flowing(
          "slug" => "quiz", "entry" => "capital",
          "nodes" => [ { "id" => "capital", "type" => "question", "question" => "Capital of France?",
                         "answers" => [ { "value" => "lyon", "weight" => 0 }, { "value" => "paris", "weight" => 1 } ] },
                       { "id" => "end", "type" => "terminal" } ],
          "edges" => [ { "from" => "capital", "to" => "end" } ]
        ))
        flow.create_version
      end
    end

    test "the answer key shows a fill-in-the-blank question with its first accepted answer typed in" do
      typed = EasyFlow::Definition.create!(host: "alembic", slug: "typed").tap do |flow|
        flow.edit_history.edit_document(flowing(
          "slug" => "typed", "entry" => "gold",
          "nodes" => [ { "id" => "gold", "type" => "fill_in_the_blank", "question" => "Symbol for gold?",
                         "accepted_answers" => [ { "value" => "Au" }, { "value" => "AU" } ] },
                       { "id" => "end", "type" => "terminal" } ],
          "edges" => [ { "from" => "gold", "to" => "end" } ]
        ))
        flow.create_version
      end

      get alembic.step_manage_flow_answer_key_path(typed)

      assert_select "input[name='answers[gold]'][value=Au]"
    end

    test "the answer key shows a single-choice question with its right answer selected" do
      get alembic.step_manage_flow_answer_key_path(quiz)

      assert_select "input[type=radio][value=paris][checked]"
    end
  end
end
