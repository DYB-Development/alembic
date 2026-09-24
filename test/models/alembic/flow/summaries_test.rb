require "test_helper"

module Alembic
  module Flow
    class SummariesTest < ActiveSupport::TestCase
      def published(slug = "demo")
        EasyFlow::Definition.create!(slug: slug).tap do |flow|
          flow.record_definition(flowing("slug" => slug, "entry" => "a",
            "nodes" => [ { "id" => "a", "type" => "question", "question" => "A?",
                           "answers" => [ { "value" => "yes", "weight" => 5 } ] } ]))
          flow.publish
        end
      end

      def summaries(flow)
        Summaries.new(flow)
      end

      test "records a summary template as a numbered version" do
        flow = published

        summaries(flow).record("outputs" => [ { "id" => "score" } ])

        assert_equal 1, SummaryVersion.where(flow: flow).sole.number
      end

      test "numbers a second summary template after the first" do
        flow = published
        summaries(flow).record("outputs" => [])

        summaries(flow).record("outputs" => [ { "id" => "score" } ])

        assert_equal 2, SummaryVersion.where(flow: flow).maximum(:number)
      end

      test "reads back the summary template at its cursor" do
        flow = published
        summaries(flow).record("outputs" => [ { "id" => "score" } ])

        assert_equal({ "outputs" => [ { "id" => "score" } ] }, summaries(flow).document)
      end

      test "recording a summary leaves the flow version untouched" do
        flow = published

        assert_no_changes -> { flow.reload.definition_cursor } do
          summaries(flow).record("outputs" => [])
        end
      end

      test "reports no summary document when none has been recorded" do
        assert_nil summaries(published).document
      end

      test "summarises from the recorded summary version" do
        flow = published

        summaries(flow).record("outputs" => [ { "id" => "score", "type" => "weighted_sum" } ])

        assert summaries(flow).any?
      end

      test "a flow's summary works out its outputs from the answers given" do
        flow = published
        summaries(flow).record("outputs" => [ { "id" => "score", "type" => "weighted_sum" } ])

        assert_equal [ 5 ], summaries(flow).of("a" => "yes").map(&:value)
      end

      test "holds no summary text until one is written" do
        assert_nil summaries(published).text
      end

      test "holds the summary text written for the flow" do
        flow = published

        summaries(flow).describe("What this asks about")

        assert_equal "What this asks about", summaries(flow).text
      end

      test "pins a run to the summary version the flow is on" do
        flow = published
        summaries(flow).record("outputs" => [])
        run = EasyFlow::Run.start(flow)

        summaries(flow).pin(run)

        assert_equal summaries(flow).current_version, summaries(flow).pinned_to(run)
      end

      test "pins nothing when the flow has no summary" do
        flow = published
        run = EasyFlow::Run.start(flow)

        summaries(flow).pin(run)

        assert_nil summaries(flow).pinned_to(run)
      end

      test "a pinned run keeps its summary version when the flow records a newer one" do
        flow = published
        summaries(flow).record("outputs" => [])
        run = EasyFlow::Run.start(flow)
        summaries(flow).pin(run)

        assert_no_changes -> { summaries(flow).pinned_to(run) } do
          summaries(flow).record("outputs" => [ { "id" => "score" } ])
        end
      end

      test "a pinned run summarises from the summary it was pinned to" do
        flow = published
        summaries(flow).record("outputs" => [ { "id" => "answered", "type" => "tally", "label" => "Steps answered" } ])
        run = EasyFlow::Run.start(flow)
        summaries(flow).pin(run)
        summaries(flow).record("outputs" => [ { "id" => "other", "type" => "tally", "label" => "Something else" } ])

        assert_equal [ "Steps answered" ], summaries(flow).of_run(run, "a" => "yes").map(&:label)
      end

      test "a pinned run summarises from the flow it was pinned to when the weights change" do
        flow = published
        summaries(flow).record("outputs" => [ { "id" => "score", "type" => "weighted_sum" } ])
        run = EasyFlow::Run.start(flow)
        summaries(flow).pin(run)
        flow.record_definition(flowing("slug" => "demo", "entry" => "a",
          "nodes" => [ { "id" => "a", "type" => "question", "question" => "A?",
                         "answers" => [ { "value" => "yes", "weight" => 99 } ] } ]))

        assert_equal [ 5 ], summaries(flow).of_run(run, "a" => "yes").map(&:value)
      end

      test "a run pinned to no summary has no outputs" do
        flow = published

        assert_empty summaries(flow).of_run(EasyFlow::Run.start(flow), "a" => "yes")
      end

      test "a flow's summary data goes with the flow" do
        flow = published
        summaries(flow).record("outputs" => [])
        summaries(flow).describe("Gone soon")
        summaries(flow).pin(EasyFlow::Run.start(flow))

        flow.destroy!

        assert_equal [ 0, 0, 0 ], [ SummaryVersion, DefinitionSummary, RunSummary ].map(&:count)
      end
    end
  end
end
