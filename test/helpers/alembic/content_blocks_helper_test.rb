require "test_helper"

module Alembic
  class ContentBlocksHelperTest < ActionView::TestCase
    tests Alembic::ContentBlocksHelper

    helper KeystoneUiHelper

    test "draws a hero's headline as the page's heading" do
      assert_select_in alembic_hero_block(headline: "What is your business not seeing?"), "h1", text: "What is your business not seeing?"
    end

    test "draws a hero's small label above its headline" do
      assert_select_in alembic_hero_block(headline: "Seeing?", kicker: "Business diagnostic"), "p.uppercase", text: "Business diagnostic"
    end

    test "draws a hero's text under its headline" do
      assert_select_in alembic_hero_block(headline: "Seeing?", text: "A three-minute check."), "p.text-lg", text: "A three-minute check."
    end

    test "fills a fact written as the question count with the count it is handed" do
      assert_select_in alembic_facts_block(question_count: 15) { "{question_count} | questions" }, "span b", text: "15"
    end

    test "draws each line after a table's first as a row of cells" do
      assert_select_in alembic_table_block { "Tier | Setup\nLive query | An index" }, "tbody td", text: "An index"
    end

    test "draws a code block's body as code" do
      assert_select_in alembic_code_block { "Order.count" }, "pre code", text: "Order.count"
    end

    test "draws a start button that links to where the flow starts" do
      assert_select_in alembic_start_block(label: "Start the scorecard", start_path: "/diagnostics/scorecard/step"),
        "a[href=?]", "/diagnostics/scorecard/step", text: "Start the scorecard"
    end

    test "draws a start button that posts when starting makes a run" do
      assert_select_in alembic_start_block(start_path: "/diagnostics/scorecard/runs", starts_a_run: true),
        "form[method=post][action=?]", "/diagnostics/scorecard/runs"
    end

    private

    def assert_select_in(html, *selector, **equality)
      assert_select Nokogiri::HTML::DocumentFragment.parse(html), *selector, equality
    end
  end
end
