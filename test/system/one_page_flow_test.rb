require "application_system_test_case"

module Alembic
  class OnePageFlowTest < ApplicationSystemTestCase
    setup do
      Flow::Summaries.new(straight).ask_on_one_page(true)
    end

    test "a one-page flow shows only its first question to begin with" do
      visit alembic.flow_step_path(straight.slug)

      assert_no_text "How careful?"
    end

    test "choosing an answer on one page shows the next question" do
      visit alembic.flow_step_path(straight.slug)

      choose "Fast", allow_label_click: true

      assert_text "How careful?"
    end

    private

    def straight
      @straight ||= EasyFlow::Definition.create!(host: "alembic", slug: "straight").tap do |flow|
        flow.record_definition(flowing("slug" => "straight", "entry" => "speed",
          "nodes" => [ { "id" => "speed", "type" => "question", "text" => "How fast?", "category" => "Pace", "required" => true,
                         "options" => [ { "value" => "fast", "label" => "Fast", "weight" => 2 }, { "value" => "slow", "label" => "Slow", "weight" => 0 } ] },
                       { "id" => "care", "type" => "question", "text" => "How careful?", "category" => "Quality", "required" => true,
                         "options" => [ { "value" => "high", "label" => "High", "weight" => 2 }, { "value" => "low", "label" => "Low", "weight" => 0 } ] } ],
          "edges" => [ { "from" => "speed", "to" => "care" } ]))
        flow.publish
        Flow::Summaries.new(flow).record("outputs" => [ { "id" => "share", "type" => "percentage", "label" => "captured" } ])
      end
    end
  end
end
