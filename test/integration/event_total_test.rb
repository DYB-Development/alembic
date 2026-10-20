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

    test "a visitor taken into a quiz inside an event has the quiz's run pinned to the quiz's summary" do
      history = quiz("history")
      post alembic.flow_runs_path(event(history).slug)

      2.times { follow_redirect! }

      assert_equal Flow::Summaries.new(history).current_version, Flow::Summaries.new(history).pinned_to(EasyFlow::Run.find_by!(flow: history))
    end
  end
end
