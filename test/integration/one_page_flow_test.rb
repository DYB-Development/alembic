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

      assert_select "[data-one-page-question]:last-of-type .ks-meter-label", text: "Question 3 of 3"
    end

    test "each question on the one-page form fills the look's progress meter with the share before it" do
      get alembic.flow_step_path(straight.slug)

      assert_select "[data-one-page-question]:last-of-type .ks-progress-track .ks-progress-bar[style=?]", "width: 67%"
    end

    test "the one-page form ends on a ready state with a button that sends every answer" do
      get alembic.flow_step_path(straight.slug)

      assert_select "[data-one-page-ready] button[type=submit]"
    end

    test "the one-page form's button that sends every answer is the look's primary button" do
      get alembic.flow_step_path(straight.slug)

      assert_select "[data-one-page-ready] button.ks-button-primary[type=submit]", text: "See my results"
    end

    test "every Previous button on the one-page form takes the look's muted text colour" do
      get alembic.flow_step_path(straight.slug)

      assert_select "button[data-one-page-previous].ks-tone-muted", 3
    end

    test "answers sent without one to a required question return the visitor to that question" do
      get alembic.flow_step_path(straight.slug), params: { answers: { speed: "fast", cost: "cheap" } }

      assert_select "input[type=hidden][name=asked][value=?]", "care"
    end

    test "answers sent on one page give the result the step-by-step pages give" do
      get alembic.flow_step_path(straight.slug), params: { answers: { speed: "fast", care: "high", cost: "dear" } }

      assert_select "[data-output=?] .text-7xl", "share", text: "67%"
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
