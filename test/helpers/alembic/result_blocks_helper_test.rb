require "test_helper"

module Alembic
  class ResultBlocksHelperTest < ActionView::TestCase
    tests Alembic::ResultBlocksHelper

    helper KeystoneUiHelper

    test "draws a score as a large percentage" do
      assert_select_in alembic_score_block(value: 64), ".text-7xl", text: "64%"
    end

    test "draws a band as a pill coloured by a low score" do
      assert_select_in alembic_band_block(value: { "name" => "Flying blind" }, score: 30), ".rounded-full.bg-red-500", text: "Flying blind"
    end

    test "draws a band's description under its pill" do
      assert_select_in alembic_band_block(value: { "name" => "Flying blind", "description" => "Most of it runs on memory." }, score: 30),
        "p", text: "Most of it runs on memory."
    end

    test "draws each category as a bar as wide as its score" do
      assert_select_in alembic_categories_block(value: { "Sales" => 30 }), "span.bg-red-500[style=?]", "width:30%"
    end

    test "keeps a category bar visible when its score is nothing" do
      assert_select_in alembic_categories_block(value: { "Sales" => 0 }), "span.bg-red-500[style=?]", "width:4%"
    end

    test "draws each weakest category in a panel headed by its name" do
      assert_select_in alembic_weakest_block(value: [ { "name" => "Hiring" } ]), ".ks-panel h3", text: "Hiring"
    end

    test "draws what a weakest category misses under its name" do
      assert_select_in alembic_weakest_block(value: [ { "name" => "Hiring", "miss" => "Hires are a guess." } ]),
        ".ks-panel p", text: "Hires are a guess."
    end

    test "draws what a weakest category costs after its label" do
      assert_select_in alembic_weakest_block(value: [ { "name" => "Hiring", "cost" => "Slow hires cost months." } ]),
        ".ks-panel p", text: "What it likely costs you: Slow hires cost months."
    end

    test "draws each answer given beside its question" do
      assert_select_in alembic_answers_block(value: [ [ "What is your budget?", "Generous" ] ]),
        "li", text: /What is your budget\?\s+Generous/
    end

    test "posts a lead to the address the host names for the flow" do
      Alembic.lead_address = ->(slug) { "/labs/#{slug}/interest" }

      assert_select_in alembic_lead_block(slug: "scorecard", note: "64%"), "form[action=?]", "/labs/scorecard/interest"
    ensure
      Alembic.lead_address = nil
    end

    test "sends the result note with a lead" do
      Alembic.lead_address = ->(slug) { "/labs/#{slug}/interest" }

      assert_select_in alembic_lead_block(slug: "scorecard", note: "64% Partially instrumented"),
        "input[type=hidden][name=note][value=?]", "64% Partially instrumented"
    ensure
      Alembic.lead_address = nil
    end

    test "sends the flow's slug with a lead" do
      Alembic.lead_address = ->(slug) { "/labs/#{slug}/interest" }

      assert_select_in alembic_lead_block(slug: "scorecard"), "input[type=hidden][name=slug][value=?]", "scorecard"
    ensure
      Alembic.lead_address = nil
    end

    test "draws the fields the host names inside the lead form" do
      Alembic.lead_address = ->(slug) { "/labs/#{slug}/interest" }
      Alembic.lead_fields_partial = "shared/lead_fields"

      assert_select_in alembic_lead_block(slug: "scorecard"), "form input[name=company_url]"
    ensure
      Alembic.lead_address = nil
      Alembic.lead_fields_partial = nil
    end

    test "colours a middling score amber" do
      assert_equal "bg-amber-500", alembic_tone(40)
    end

    test "colours a strong score green" do
      assert_equal "bg-emerald-500", alembic_tone(70)
    end

    private

    def assert_select_in(html, *selector, **equality)
      assert_select Nokogiri::HTML::DocumentFragment.parse(html), *selector, equality
    end
  end
end
