require "test_helper"

module Alembic
  class OnePageFlowTest < ActionDispatch::IntegrationTest
    setup do
      Flow::Summaries.new(straight).ask_on_one_page(true)
    end

    test "a visitor opening a flow on one page is given every question in one form" do
      get alembic.flow_step_path(straight.slug)

      assert_select "form fieldset", 3
    end

    test "choosing an answer on the one-page form does not send the form" do
      get alembic.flow_step_path(straight.slug)

      assert_select "input[type=radio][onchange]", 0
    end

    test "each question on the one-page form counts itself out of every question" do
      get alembic.flow_step_path(straight.slug)

      assert_select "[data-one-page-question]:last-of-type span", text: "Question 3 of 3"
    end

    private

    def straight
      @straight ||= EasyFlow::Definition.create!(host: "alembic", slug: "straight").tap do |flow|
        flow.record_definition(flowing("slug" => "straight", "entry" => "speed",
          "nodes" => [ { "id" => "speed", "type" => "question", "text" => "How fast?", "category" => "Pace", "required" => true,
                         "options" => [ { "value" => "fast", "label" => "Fast", "weight" => 2 }, { "value" => "slow", "label" => "Slow", "weight" => 0 } ] },
                       { "id" => "care", "type" => "question", "text" => "How careful?", "category" => "Quality", "required" => true,
                         "options" => [ { "value" => "high", "label" => "High", "weight" => 2 }, { "value" => "low", "label" => "Low", "weight" => 0 } ] },
                       { "id" => "cost", "type" => "question", "text" => "How cheap?", "category" => "Price", "required" => true,
                         "options" => [ { "value" => "cheap", "label" => "Cheap", "weight" => 2 }, { "value" => "dear", "label" => "Dear", "weight" => 0 } ] } ],
          "edges" => [ { "from" => "speed", "to" => "care" }, { "from" => "care", "to" => "cost" } ]))
        flow.publish
        Flow::Summaries.new(flow).record("outputs" => [ { "id" => "share", "type" => "percentage", "label" => "captured" } ])
      end
    end
  end
end
