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

      test "falls through to a later rule when an earlier one does not hold" do
        assert_equal "Live query", chosen("need" => "now")["name"]
      end

      test "a condition that an answer is not a value holds for any other answer" do
        rules = { "entries" => config["entries"], "rules" => [ { "entry" => "rollup", "when" => [ { "step" => "need", "is_not" => "now" } ] } ] }

        assert_equal "Rollup", Outcome.output_type.compute(rules, Summary::Run.new(state: { "need" => "rates" }), {})["chosen"]["name"]
      end
    end
  end
end
