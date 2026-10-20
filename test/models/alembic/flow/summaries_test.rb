require "test_helper"

module Alembic
  module Flow
    class SummariesTest < ActiveSupport::TestCase
      def published(slug = "demo")
        EasyFlow::Definition.create!(host: "alembic", slug: slug).tap do |flow|
          flow.record_definition(flowing("slug" => slug, "entry" => "a",
            "nodes" => [ { "id" => "a", "type" => "question", "question" => "A?",
                           "answers" => [ { "value" => "yes", "weight" => 5 } ] } ]))
          flow.publish
        end
      end

      def summaries(flow)
        Summaries.new(flow)
      end

      def kept_run(flow, score:, seconds_taken: nil)
        EasyFlow::Run.start(flow).tap do |run|
          summaries(flow).pin(run)
          RunSummary.find_by(run: run).update!(score: score, seconds_taken: seconds_taken)
        end
      end

      test "records that a flow shows each answer's value beside its label" do
        flow = published

        summaries(flow).show_answer_values(true)

        assert summaries(flow).shows_answer_values?
      end

      test "records that a flow asks every question on one page" do
        flow = published

        summaries(flow).ask_on_one_page(true)

        assert summaries(flow).asks_on_one_page?
      end

      test "records the page a flow starts on" do
        flow = published
        page = Page.create!(name: "Welcome")

        summaries(flow).start_on(page)

        assert_equal page, summaries(flow).intro_page
      end

      test "records the page a flow finishes on" do
        flow = published
        page = Page.create!(name: "Result")

        summaries(flow).finish_on(page)

        assert_equal page, summaries(flow).summary_page
      end

      test "refuses an output that names a type nobody registered, naming the type" do
        error = assert_raises(Summary::UnknownOutputType) do
          summaries(published).record("outputs" => [ { "id" => "mood", "type" => "vibes" } ])
        end

        assert_match "vibes", error.message
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

      test "keeps a finished run's score from the first weighted sum in its summary" do
        flow = published
        summaries(flow).record("outputs" => [ { "id" => "answered", "type" => "tally" }, { "id" => "score", "type" => "weighted_sum" } ])
        run = EasyFlow::Run.start(flow)
        summaries(flow).pin(run)

        summaries(flow).keep(run, "a" => "yes")

        assert_equal 5, RunSummary.find_by(run: run).score
      end

      test "keeps no score for a run whose summary has no weighted sum" do
        flow = published
        summaries(flow).record("outputs" => [ { "id" => "answered", "type" => "tally" } ])
        run = EasyFlow::Run.start(flow)
        summaries(flow).pin(run)

        summaries(flow).keep(run, "a" => "yes")

        assert_nil RunSummary.find_by(run: run).score
      end

      test "keeps the seconds from a run's start to its last answer when the flow saves every answer" do
        flow = published
        flow.update!(persists: :each_step)
        summaries(flow).record("outputs" => [])
        run = travel_to(Time.zone.local(2026, 10, 20, 9, 0, 0)) { EasyFlow::Run.start(flow) }
        summaries(flow).pin(run)
        travel_to(Time.zone.local(2026, 10, 20, 9, 1, 30)) { run.record(:a, "yes") }

        summaries(flow).keep(run, "a" => "yes")

        assert_equal 90, RunSummary.find_by(run: run).seconds_taken
      end

      test "keeps no time for a run the flow saves only once it finishes" do
        flow = published
        flow.update!(persists: :on_finish)
        summaries(flow).record("outputs" => [])
        run = travel_to(Time.zone.local(2026, 10, 20, 9, 5, 0)) { EasyFlow::Run.start(flow) }
        run.update!(recorded: { "a" => { "value" => "yes", "completed_at" => "2026-10-20T09:01:00Z" } })
        summaries(flow).pin(run)

        summaries(flow).keep(run, "a" => "yes")

        assert_nil RunSummary.find_by(run: run).seconds_taken
      end

      test "keeping a run's results again leaves the score and time already kept" do
        flow = published
        flow.update!(persists: :each_step)
        summaries(flow).record("outputs" => [ { "id" => "score", "type" => "weighted_sum" } ])
        run = travel_to(Time.zone.local(2026, 10, 20, 9, 0, 0)) { EasyFlow::Run.start(flow) }
        summaries(flow).pin(run)
        travel_to(Time.zone.local(2026, 10, 20, 9, 1, 30)) { run.record(:a, "yes") }
        summaries(flow).keep(run, "a" => "yes")
        travel_to(Time.zone.local(2026, 10, 20, 9, 3, 0)) { run.record(:a, "no") }

        summaries(flow).keep(run, "a" => "no")

        assert_equal [ 5, 90 ], RunSummary.find_by(run: run).values_at(:score, :seconds_taken)
      end

      test "keeps nothing for a run pinned to no summary" do
        flow = published

        assert_no_difference -> { RunSummary.count } do
          summaries(flow).keep(EasyFlow::Run.start(flow), "a" => "yes")
        end
      end

      test "ranks a flow's finished runs with the higher score first" do
        flow = published
        summaries(flow).record("outputs" => [])
        lower = kept_run(flow, score: 3)
        higher = kept_run(flow, score: 8)

        assert_equal [ higher, lower ], summaries(flow).ranked.map(&:run)
      end

      test "ranks the shorter time first between two runs with the same score" do
        flow = published
        summaries(flow).record("outputs" => [])
        slower = kept_run(flow, score: 5, seconds_taken: 120)
        faster = kept_run(flow, score: 5, seconds_taken: 45)

        assert_equal [ faster, slower ], summaries(flow).ranked.map(&:run)
      end

      test "ranks a run with no time last among runs with the same score" do
        flow = published
        summaries(flow).record("outputs" => [])
        untimed = kept_run(flow, score: 5)
        timed = kept_run(flow, score: 5, seconds_taken: 300)

        assert_equal [ timed, untimed ], summaries(flow).ranked.map(&:run)
      end

      test "ranks only the flow's own runs" do
        flow = published
        other = published("other")
        [ flow, other ].each { |each| summaries(each).record("outputs" => []) }
        own = kept_run(flow, score: 1)
        kept_run(other, score: 9)

        assert_equal [ own ], summaries(flow).ranked.map(&:run)
      end

      test "ranks no run that has no score kept" do
        flow = published
        summaries(flow).record("outputs" => [])
        finished = kept_run(flow, score: 2)
        summaries(flow).pin(EasyFlow::Run.start(flow))

        assert_equal [ finished ], summaries(flow).ranked.map(&:run)
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
