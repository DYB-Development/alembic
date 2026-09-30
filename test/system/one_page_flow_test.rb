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

    test "Previous on one page shows the question before with its answer kept" do
      visit alembic.flow_step_path(straight.slug)
      choose "Fast", allow_label_click: true

      click_on "← Previous"

      within("[data-one-page-question]:not([hidden])") { assert_checked_field "Fast", visible: :all }
    end

    test "answering every question on one page sends them all in one request" do
      visit alembic.flow_step_path(straight.slug)
      choose "Fast", allow_label_click: true
      choose "High", allow_label_click: true

      click_on "See my results"

      assert_selector ".text-7xl", text: "100%"
    end

    test "Previous on the ready state shows the last question again" do
      visit alembic.flow_step_path(straight.slug)
      choose "Fast", allow_label_click: true
      choose "High", allow_label_click: true

      within("[data-one-page-ready]") { click_on "← Previous" }

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
