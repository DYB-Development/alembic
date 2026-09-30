require "test_helper"

module Alembic
  class ResultBlocksHelperTest < ActionView::TestCase
    tests Alembic::ResultBlocksHelper

    include KeystoneUiHelper

    test "draws a score as a large percentage" do
      assert_select_in alembic_score_block(value: 64), ".text-7xl", text: "64%"
    end

    private

    def assert_select_in(html, selector, **equality)
      assert_select Nokogiri::HTML::DocumentFragment.parse(html), selector, equality
    end
  end
end
