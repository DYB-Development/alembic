require "test_helper"

module Alembic
  class ResultBlocksHelperTest < ActionView::TestCase
    tests Alembic::ResultBlocksHelper

    include KeystoneUiHelper

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
