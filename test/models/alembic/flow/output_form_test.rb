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

      test "reads an outcome entry's sections one per line as a heading, text and result note" do
        entry = edited("entries" => { "0" => { "key" => "live", "sections_text" => "Why it works | Always correct.\nAvoiding it | Cache it. | Stale numbers." } })["entries"].first

        assert_equal [ { "heading" => "Why it works", "text" => "Always correct.", "note" => nil },
                       { "heading" => "Avoiding it", "text" => "Cache it.", "note" => "Stale numbers." } ], entry["sections"]
      end

      test "reads an outcome entry's steps as a title line and code, split by a line of three dashes" do
        entry = edited("entries" => { "0" => { "key" => "live", "steps_text" => "Add an index\nadd_index :orders, :status\n---\nQuery it\nOrder.count" } })["entries"].first

        assert_equal [ { "title" => "Add an index", "code" => "add_index :orders, :status" }, { "title" => "Query it", "code" => "Order.count" } ], entry["steps"]
      end

      test "leaves out a new output saved without an id" do
        assert_empty OutputForm.edited([], { "0" => { "id" => "", "type" => "outcome" } })
      end
    end
  end
end
