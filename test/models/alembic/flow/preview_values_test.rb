require "test_helper"

module Alembic
  module Flow
    class PreviewValuesTest < ActiveSupport::TestCase
      test "previews a page a flow finishes on with results from a sample run" do
        page = Page.create!(name: "Result")
        Summaries.new(scored_flow).finish_on(page)

        assert_equal 50, PreviewValues.values(page, nil)["share"]
      end

      test "previews a page a flow starts on with the flow's question count" do
        page = Page.create!(name: "Welcome")
        Summaries.new(scored_flow).start_on(page)

        assert_equal 2, PreviewValues.values(page, nil)["question_count"]
      end

      private

      def scored_flow
        @scored_flow ||= EasyFlow::Definition.create!(host: "alembic", slug: "scored").tap do |flow|
          flow.record_definition(flowing("slug" => "scored", "entry" => "a",
            "nodes" => [ { "id" => "a", "type" => "question", "text" => "A?", "options" => [ { "value" => "y", "weight" => 2 }, { "value" => "n", "weight" => 0 } ] },
                         { "id" => "b", "type" => "question", "text" => "B?", "options" => [ { "value" => "y", "weight" => 2 }, { "value" => "n", "weight" => 0 } ] } ],
            "edges" => [ { "from" => "a", "to" => "b" } ]))
          flow.publish
          Summaries.new(flow).record("outputs" => [ { "id" => "share", "type" => "percentage" } ])
        end
      end
    end
  end
end
