require "test_helper"

module Alembic
  module Flow
    class RunSummaryTest < ActiveSupport::TestCase
      test "keeps a finished run's score and the seconds it took" do
        flow = EasyFlow::Definition.create!(host: "alembic", slug: "kept").tap do |defined|
          defined.record_definition(flowing("slug" => "kept", "entry" => "a",
            "nodes" => [ { "id" => "a", "type" => "question", "question" => "A?", "answers" => [ { "value" => "yes" } ] } ]))
          defined.publish
        end
        version = Summaries.new(flow).record("outputs" => [])

        kept = RunSummary.create!(run: EasyFlow::Run.start(flow), summary_version: version, score: 7, seconds_taken: 42)

        assert_equal [ 7, 42 ], kept.reload.values_at(:score, :seconds_taken)
      end
    end
  end
end
