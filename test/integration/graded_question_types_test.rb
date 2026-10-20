require "test_helper"

module Alembic
  class GradedQuestionTypesTest < ActionDispatch::IntegrationTest
    def quiz
      { "slug" => "mixed", "entry" => "flags",
        "nodes" => [ { "id" => "flags", "type" => "multiple_select", "question" => "Which colours are on the French flag?",
                       "answers" => [ { "value" => "blue", "weight" => 2 }, { "value" => "red", "weight" => 2 }, { "value" => "green" } ] },
                     { "id" => "capital", "type" => "fill_in_the_blank", "question" => "What is the capital of France?",
                       "accepted_answers" => [ { "value" => "Paris" } ] } ],
        "edges" => [ { "from" => "flags", "to" => "capital" } ] }
    end

    def mixed
      @mixed ||= EasyFlow::Definition.create!(host: "alembic", slug: "mixed", persists: :each_step).tap { |flow| flow.record_definition(flowing(quiz)); flow.publish }
    end

    test "a run answering multiple select and fill in the blank questions shows and keeps their score" do
      Flow::Summaries.new(mixed).record("outputs" => [ { "id" => "score", "type" => "weighted_sum", "label" => "Your score" } ])
      post alembic.flow_runs_path(mixed.slug)
      run = EasyFlow::Run.last
      patch alembic.run_path(run), params: { answers: { flags: [ "red", "blue" ] } }
      patch alembic.run_path(run), params: { answers: { capital: " paris " } }

      get alembic.run_path(run)

      assert_select "[data-output=?]", "score", text: /2/
      assert_equal 2, Flow::RunSummary.find_by(run: run).score
    end
  end
end
