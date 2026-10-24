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

    test "a player sees a checkbox for each option of a multiple select question" do
      post alembic.flow_runs_path(mixed.slug)

      get alembic.run_path(EasyFlow::Run.last)

      assert_select "input[type=checkbox][name=?]", "answers[flags][]", count: 3
    end

    test "ticking an option of a multiple select question does not move the player on" do
      post alembic.flow_runs_path(mixed.slug)

      get alembic.run_path(EasyFlow::Run.last)

      assert_select "input[type=checkbox][name=?]:not([onchange])", "answers[flags][]", count: 3
    end

    test "a quiz asked on one page shows a checkbox for each option of a multiple select question" do
      Flow::Summaries.new(mixed).ask_on_one_page(true)

      get alembic.flow_step_path(mixed.slug)

      assert_select "input[type=checkbox][name=?]", "answers[flags][]", count: 3
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

    test "a player who ticks exactly the right options of a multiple select question sees it marked right" do
      run = finished(flags: [ "red", "blue" ], capital: "Lyon")

      get alembic.run_path(run)

      assert_select "[data-answer=flags] [aria-label=Right]"
    end

    test "a player who types an accepted answer to a fill in the blank question sees it marked right" do
      run = finished(flags: [ "green" ], capital: " paris ")

      get alembic.run_path(run)

      assert_select "[data-answer=capital] [aria-label=Right]"
    end

    test "a player's wrong answers to multiple select and fill in the blank questions are not marked right" do
      run = finished(flags: [ "green" ], capital: "Lyon")

      get alembic.run_path(run)

      assert_select "[aria-label=Right]", 0
    end

    private

    def finished(flags:, capital:)
      mixed.update!(kind: "scored")
      Flow::Summaries.new(mixed).record("outputs" => [ { "id" => "score", "type" => "weighted_sum", "label" => "Your score" } ])
      post alembic.flow_runs_path(mixed.slug)
      EasyFlow::Run.last.tap do |run|
        patch alembic.run_path(run), params: { answers: { flags: flags } }
        patch alembic.run_path(run), params: { answers: { capital: capital } }
      end
    end
  end
end
