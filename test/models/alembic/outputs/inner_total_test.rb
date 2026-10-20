require "test_helper"

module Alembic
  module Outputs
    class InnerTotalTest < ActiveSupport::TestCase
      def saved(slug, document)
        EasyFlow::Definition.create!(host: "alembic", slug: slug, persists: :each_step).tap { |flow| flow.record_definition(flowing(document)); flow.publish }
      end

      def quiz
        @quiz ||= saved("quiz", "slug" => "quiz", "entry" => "ask",
          "nodes" => [ { "id" => "ask", "type" => "question", "text" => "Right?",
                         "options" => [ { "value" => "right", "weight" => 1 }, { "value" => "wrong" } ] },
                       { "id" => "more", "type" => "question", "text" => "Again?",
                         "options" => [ { "value" => "right", "weight" => 1 }, { "value" => "wrong" } ] },
                       { "id" => "done", "type" => "terminal", "output" => "1" } ],
          "edges" => [ { "from" => "ask", "to" => "more" }, { "from" => "more", "to" => "done" } ]).tap do |flow|
          Flow::Summaries.new(flow).record("outputs" => [ { "id" => "score", "type" => "weighted_sum" } ])
        end
      end

      def event
        saved("event", "slug" => "event", "entry" => "first",
          "nodes" => [ { "id" => "first", "type" => "flow_step", "flow" => quiz.id.to_s, "version" => 1 },
                       { "id" => "second", "type" => "flow_step", "flow" => quiz.id.to_s, "version" => 1 },
                       { "id" => "done", "type" => "terminal" } ],
          "edges" => [ { "from" => "first", "to" => "second", "on" => "1" }, { "from" => "second", "to" => "done", "on" => "1" } ])
      end

      def answered(parent, step, answer)
        parent.advance
        parent.inner_runs.find_by!(parent_step: step).tap do |inner|
          Flow::Summaries.new(quiz).pin(inner)
          inner.record(:ask, answer)
          inner.record(:more, "wrong")
          inner.advance
        end
      end

      def total(parent)
        InnerTotal.output_type.compute({}, Summary::Run.new(state: {}, steps: {}, run: parent), {})
      end

      test "adds up the score of every inner run the run started" do
        parent = EasyFlow::Run.start(event)
        answered(parent, "first", "right")
        answered(parent, "second", "right")

        assert_equal 2, total(parent)
      end

      test "adds nothing for an inner run that has not ended" do
        parent = EasyFlow::Run.start(event)
        answered(parent, "first", "right")
        parent.advance
        Flow::Summaries.new(quiz).pin(parent.inner_runs.find_by!(parent_step: "second").tap { |inner| inner.record(:ask, "right") })

        assert_equal 1, total(parent)
      end

      test "totals nothing for answers that belong to no saved run" do
        assert_equal 0, InnerTotal.output_type.compute({}, Summary::Run.new(state: {}, steps: {}), {})
      end
    end
  end
end
