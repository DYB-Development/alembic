require "test_helper"

module Alembic
  module Flow
    class OutputFormTest < ActiveSupport::TestCase
      def edited(output)
        OutputForm.edited([ { "id" => "tier", "type" => "outcome" } ], { "0" => output }).first
      end

      test "reads an outcome's rules one per line, in order" do
        rules = edited("rules_text" => "rollup: need is trend, loss is not never\nlive:")["rules"]

        assert_equal [ { "entry" => "rollup", "when" => [ { "step" => "need", "is" => "trend" }, { "step" => "loss", "is_not" => "never" } ] },
                       { "entry" => "live", "when" => [] } ], rules
      end

      test "reads an outcome entry's facts one per line as a label and value" do
        entry = edited("entries" => { "0" => { "key" => "live", "name" => "Live query", "facts_text" => "Setup | An index\nMaintenance | none" } })["entries"].first

        assert_equal [ [ "Setup", "An index" ], [ "Maintenance", "none" ] ], entry["facts"]
      end
    end
  end
end
