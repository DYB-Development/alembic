require "test_helper"

module Alembic
  class SavedSessionsTest < ActionDispatch::IntegrationTest
    def branching
      { "slug" => "saved", "entry" => "budget",
        "nodes" => [ { "id" => "budget", "type" => "question", "text" => "Budget?",
                       "options" => [ { "value" => "low", "label" => "Modest" }, { "value" => "high", "label" => "Generous" } ] },
                     { "id" => "gate", "type" => "condition", "step" => "budget", "output" => "answer", "comparison" => "is", "answer" => "high" },
                     { "id" => "posh", "type" => "question", "text" => "Premium tier?", "options" => [ "gold" ] },
                     { "id" => "plain", "type" => "question", "text" => "Basic tier?", "options" => [ "bronze" ] } ],
        "edges" => [ { "from" => "budget", "to" => "gate" },
                     { "from" => "gate", "to" => "posh", "on" => true },
                     { "from" => "gate", "to" => "plain", "on" => false } ] }
    end

    def saved
      @saved ||= EasyFlow::Definition.create!(slug: "saved", persists: :each_step).tap { |flow| flow.record_definition(flowing(branching)); flow.publish }
    end

    def summaries
      Flow::Summaries.new(saved)
    end

    test "starting a saved session sends the visitor to its address under alembic" do
      post alembic.flow_runs_path(saved.slug)

      assert_redirected_to alembic.run_path(EasyFlow::Run.last)
    end

    test "starting a saved session pins it to the summary the flow is on" do
      summaries.record("outputs" => [ { "id" => "answered", "type" => "tally" } ])

      post alembic.flow_runs_path(saved.slug)

      assert_equal summaries.current_version, summaries.pinned_to(EasyFlow::Run.last)
    end

    test "a saved session submits its answers back to its address under alembic" do
      run = EasyFlow::Run.start(saved)

      get alembic.run_path(run)

      assert_select "form[action=?]", alembic.run_path(run)
    end

    test "answering a step sends the visitor back to the run's address under alembic" do
      run = EasyFlow::Run.start(saved)

      patch alembic.run_path(run), params: { answers: { budget: "high" } }

      assert_redirected_to alembic.run_path(run)
    end

    test "a completed saved session lists what was said" do
      run = EasyFlow::Run.start(saved)
      run.record(:budget, "low")
      run.record(:plain, "bronze")

      get alembic.run_path(run)

      assert_select "[data-answer=?]", "budget"
    end

    test "the intro offers to start a saved session" do
      get alembic.flow_path(saved.slug)

      assert_select "form[action=?]", alembic.flow_runs_path(saved.slug)
    end

    test "a completed saved session shows its pinned summary's outputs" do
      summaries.record("outputs" => [ { "id" => "answered", "type" => "tally", "label" => "Steps answered" } ])
      post alembic.flow_runs_path(saved.slug)
      run = EasyFlow::Run.last
      run.record(:budget, "low")
      run.record(:plain, "bronze")
      summaries.record("outputs" => [ { "id" => "other", "type" => "tally", "label" => "Something else" } ])

      get alembic.run_path(run)

      assert_select "[data-output=?]", "answered"
    end

    test "a visitor part way through a withdrawn version is told it was withdrawn" do
      Alembic.refusal_method = :note_the_refusal
      run = EasyFlow::Run.start(saved)
      run.definition_version.update!(status: :withdrawn)

      get alembic.run_path(run)

      assert_equal Alembic::Withdrawn.name, response.headers["X-Refusal"]
    ensure
      Alembic.refusal_method = nil
    end
  end
end
