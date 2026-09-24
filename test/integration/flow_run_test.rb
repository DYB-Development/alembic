require "test_helper"

module Alembic
  class FlowRunTest < ActionDispatch::IntegrationTest
    def flowed
      @flowed ||= EasyFlow::Definition.create!(host: "alembic", slug: "flowed").tap do |flow|
        flow.record_definition(flowing(
          "slug" => "flowed", "entry" => "budget",
          "nodes" => [ { "id" => "budget", "type" => "question", "text" => "What is your budget?", "tag" => "money",
                         "options" => [ { "value" => "low", "label" => "Modest", "weight" => 1 },
                                        { "value" => "high", "label" => "Generous", "weight" => 5 } ] },
                       { "id" => "gate", "type" => "condition", "step" => "budget", "output" => "answer", "comparison" => "is", "answer" => "high" },
                       { "id" => "posh", "type" => "question", "text" => "Which premium tier?",
                         "options" => [ { "value" => "a", "weight" => 3 } ] },
                       { "id" => "plain", "type" => "question", "text" => "Which basic tier?",
                         "options" => [ { "value" => "b", "weight" => 1 } ] } ],
          "edges" => [ { "from" => "budget", "to" => "gate" },
                       { "from" => "gate", "to" => "posh", "on" => true },
                       { "from" => "gate", "to" => "plain", "on" => false } ]
        ))
        flow.publish
      end
    end

    def summarised
      flowed.tap do |flow|
        Flow::Summaries.new(flow).record(
          "outputs" => [
            { "id" => "score", "type" => "weighted_sum", "label" => "Your score" },
            { "id" => "band", "type" => "band", "label" => "Where that puts you", "of" => "score",
              "bands" => [ { "ceiling" => 4, "name" => "Modest" }, { "name" => "Generous" } ] },
            { "id" => "areas", "type" => "grouped", "label" => "By area" },
            { "id" => "answered", "type" => "tally", "label" => "Steps answered" }
          ]
        )
      end
    end

    test "a flow keeping a run at the end stores it once the flow finishes" do
      flowed.update!(persists: :on_finish)

      assert_difference -> { EasyFlow::Run.count }, 1 do
        get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "high", posh: "a" } }
      end
    end

    test "a run kept at the end is pinned to the summary the flow is on" do
      summarised.update!(persists: :on_finish)

      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_equal Flow::Summaries.new(flowed).current_version, Flow::Summaries.new(flowed).pinned_to(EasyFlow::Run.last)
    end

    test "a finished run shows what its summary makes of it" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?]", "score", text: /8/
    end

    test "a finished run names the band its score falls in" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?]", "band", text: /Generous/
    end

    test "an answer stranded on an abandoned branch does not count toward the score" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "low", posh: "a", plain: "b" } }

      assert_select "[data-output=?]", "score", text: /2/
    end

    test "a finished run reports a share for each area it touched" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?]", "areas", text: /money/
    end

    test "a finished run counts the steps it answered" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?]", "answered", text: /2/
    end

    test "a flow with no summary still shows what was said" do
      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "low", plain: "b" } }

      assert_select "[data-answer=?]", "budget"
    end

    test "the finished page offers to start over at alembic's address for the flow" do
      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "low", plain: "b" } }

      assert_select "a[href=?]", alembic.flow_path(flowed.slug)
    end

    test "the intro shows the flow's summary under its title" do
      Flow::Summaries.new(flowed).describe("What this asks about")

      get alembic.flow_path(flowed.slug)

      assert_includes response.body, "What this asks about"
    end

    test "the intro links into the flow" do
      get alembic.flow_path(flowed.slug)

      assert_select "a[href=?]", alembic.flow_step_path(flowed.slug)
    end

    test "a visitor is asked the step the flow begins at" do
      get alembic.flow_step_path(flowed.slug)

      assert_select "legend", text: /What is your budget\?/
    end

    test "answering sends the visitor down the branch their answer selects" do
      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "high" } }

      assert_select "legend", text: /Which premium tier\?/
    end
  end
end
