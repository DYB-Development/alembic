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

    test "colours a middling score amber" do
      assert_equal "bg-amber-500", alembic_tone(40)
    end

    private

    def assert_select_in(html, selector, **equality)
      assert_select Nokogiri::HTML::DocumentFragment.parse(html), selector, equality
    end
  end
end
