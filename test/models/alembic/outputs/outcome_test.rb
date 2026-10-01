require "test_helper"

module Alembic
  module Outputs
    class OutcomeTest < ActiveSupport::TestCase
      def config
        { "entries" => [ { "key" => "live", "name" => "Live query" }, { "key" => "rollup", "name" => "Rollup" } ],
          "rules" => [ { "entry" => "rollup", "when" => [ { "step" => "need", "is" => "trend" } ] },
                       { "entry" => "live", "when" => [] } ] }
      end

      def chosen(state)
        Outcome.output_type.compute(config, Summary::Run.new(state: state), {})["chosen"]
      end

      test "chooses the entry named by the first rule whose conditions all hold" do
        assert_equal "Rollup", chosen("need" => "trend")["name"]
      end
    end
  end
end
