require "test_helper"

module Alembic
  class AnswerKeyTest < ActionDispatch::IntegrationTest
    def quiz
      @quiz ||= EasyFlow::Definition.create!(host: "alembic", slug: "quiz").tap do |flow|
        flow.edit_history.edit_document(flowing(
          "slug" => "quiz", "entry" => "capital",
          "nodes" => [ { "id" => "capital", "type" => "question", "question" => "Capital of France?",
                         "answers" => [ { "value" => "lyon", "weight" => 0 }, { "value" => "paris", "weight" => 1 } ] },
                       { "id" => "river", "type" => "question", "question" => "River through Paris?",
                         "answers" => [ { "value" => "seine", "weight" => 1 }, { "value" => "rhone", "weight" => 0 } ] },
                       { "id" => "end", "type" => "terminal" } ],
          "edges" => [ { "from" => "capital", "to" => "river" }, { "from" => "river", "to" => "end" } ]
        ))
        flow.create_version
      end
    end

    test "walking through the answer key to the end saves no run and no score" do
      Flow::Summaries.new(quiz).record("outputs" => [ { "id" => "score", "type" => "weighted_sum", "label" => "Score" } ])

      assert_no_difference [ "EasyFlow::Run.count", "Alembic::Flow::RunSummary.count" ] do
        get alembic.step_manage_flow_answer_key_path(quiz)
        get alembic.step_manage_flow_answer_key_path(quiz), params: { asked: "capital", answers: { capital: "paris" } }
        get alembic.step_manage_flow_answer_key_path(quiz), params: { asked: "river", answers: { capital: "paris", river: "seine" } }
      end
    end

    test "an owner cannot open the answer key of another owner's quiz" do
      Alembic.owner_method = :current_customer
      ours = Customer.create!(name: "Ours")
      theirs = EasyFlow::Definition.create!(host: "alembic", slug: "theirs", owner: Customer.create!(name: "Theirs"))

      get alembic.step_manage_flow_answer_key_path(theirs), headers: { "X-Customer" => ours.id.to_s }

      assert_response :not_found
    ensure
      Alembic.owner_method = nil
    end

    test "moving on from a question keeps the owner in the answer key" do
      get alembic.step_manage_flow_answer_key_path(quiz)

      assert_select "form[action=?]", alembic.step_manage_flow_answer_key_path(quiz)
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
