require "test_helper"

module Alembic
  class EventTotalTest < ActionDispatch::IntegrationTest
    def saved(slug, document)
      EasyFlow::Definition.create!(host: "alembic", slug: slug, persists: :each_step).tap { |flow| flow.record_definition(flowing(document)); flow.publish }
    end

    def quiz(slug)
      saved(slug, "slug" => slug, "entry" => "ask",
        "nodes" => [ { "id" => "ask", "type" => "question", "text" => "#{slug}?",
                       "options" => [ { "value" => "right", "weight" => 1 }, { "value" => "wrong" } ] },
                     { "id" => "done", "type" => "terminal", "output" => "1" } ],
        "edges" => [ { "from" => "ask", "to" => "done" } ]).tap do |flow|
        Flow::Summaries.new(flow).record("outputs" => [ { "id" => "score", "type" => "weighted_sum" } ])
      end
    end

    def event(*quizzes)
      steps = quizzes.each_with_index.map { |quiz, index| { "id" => "quiz_#{index}", "type" => "flow_step", "flow" => quiz.id.to_s, "version" => 1 } }
      edges = steps.each_cons(2).map { |from, to| { "from" => from["id"], "to" => to["id"], "on" => "1" } }
      saved("event", "slug" => "event", "entry" => steps.first["id"],
        "nodes" => steps + [ { "id" => "done", "type" => "terminal" } ],
        "edges" => edges + [ { "from" => steps.last["id"], "to" => "done", "on" => "1" } ])
    end

    def answer(step, value)
      patch request.path, params: { answers: { step => value } }
      follow_redirect! while redirect?
    end

    test "an event with two quizzes played through the visitor pages keeps the sum of both quizzes' scores" do
      history = quiz("history")
      science = quiz("science")
      played = event(history, science)
      patch easy_flow.manage_flow_path(played), params: { flow: { outputs: { "0" => { id: "total", type: "inner_total" } } } }

      post alembic.flow_runs_path(played.slug)
      follow_redirect! while redirect?
      answer(:ask, "right")
      answer(:ask, "right")

      assert_equal 2, Flow::RunSummary.find_by!(run: EasyFlow::Run.find_by!(flow: played)).score
    end

    test "an event played through the visitor pages keeps the seconds from its start to its last answer" do
      played = event(quiz("history"), quiz("science"))
      Flow::Summaries.new(played).record("outputs" => [ { "id" => "total", "type" => "inner_total" } ])

      travel_to(Time.zone.local(2026, 10, 20, 9, 0, 0)) { post alembic.flow_runs_path(played.slug); follow_redirect! while redirect? }
      travel_to(Time.zone.local(2026, 10, 20, 9, 0, 40)) { answer(:ask, "right") }
      travel_to(Time.zone.local(2026, 10, 20, 9, 1, 30)) { answer(:ask, "wrong") }

      assert_equal 90, Flow::RunSummary.find_by!(run: EasyFlow::Run.find_by!(flow: played)).seconds_taken
    end

    def play(flow, minutes, *answers)
      started = Time.zone.local(2026, 10, 20, 9, 0, 0)
      travel_to(started) { post alembic.flow_runs_path(flow.slug); follow_redirect! while redirect? }
      travel_to(started + minutes.minutes) { answers.each { |value| answer(:ask, value) } }
      EasyFlow::Run.where(flow: flow).order(:id).last
    end

    test "an event's finished runs are listed by total and then by time" do
      played = event(quiz("history"), quiz("science"))
      Flow::Summaries.new(played).record("outputs" => [ { "id" => "total", "type" => "inner_total" } ])
      slow = play(played, 5, "right", "right")
      low = play(played, 1, "right", "wrong")
      fast = play(played, 2, "right", "right")

      assert_equal [ fast, slow, low ], Flow::Summaries.new(played).ranked.map(&:run)
    end

    test "a quiz played inside an event keeps its own score" do
      history = quiz("history")
      post alembic.flow_runs_path(event(history).slug)
      follow_redirect! while redirect?

      answer(:ask, "right")

      assert_equal 1, Flow::RunSummary.find_by!(run: EasyFlow::Run.find_by!(flow: history)).score
    end

    test "a quiz played inside an event keeps the seconds from its start to its last answer" do
      history = quiz("history")
      travel_to(Time.zone.local(2026, 10, 20, 9, 0, 0)) { post alembic.flow_runs_path(event(history).slug); follow_redirect! while redirect? }

      travel_to(Time.zone.local(2026, 10, 20, 9, 0, 45)) { answer(:ask, "right") }

      assert_equal 45, Flow::RunSummary.find_by!(run: EasyFlow::Run.find_by!(flow: history)).seconds_taken
    end

    test "a quiz played inside an event is listed among the quiz's own ranked attempts" do
      history = quiz("history")
      post alembic.flow_runs_path(event(history).slug)
      follow_redirect! while redirect?
      answer(:ask, "right")
      inside = EasyFlow::Run.find_by!(flow: history)
      own = play(history, 1, "wrong")

      assert_equal [ inside, own ], Flow::Summaries.new(history).ranked.map(&:run)
    end

    test "a visitor taken into a quiz inside an event has the quiz's run pinned to the quiz's summary" do
      history = quiz("history")
      post alembic.flow_runs_path(event(history).slug)

      2.times { follow_redirect! }

      assert_equal Flow::Summaries.new(history).current_version, Flow::Summaries.new(history).pinned_to(EasyFlow::Run.find_by!(flow: history))
    end
  end
end
