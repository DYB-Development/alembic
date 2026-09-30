require "test_helper"

module Alembic
  class ContentBlocksHelperTest < ActionView::TestCase
    tests Alembic::ContentBlocksHelper

    helper KeystoneUiHelper

    test "draws a hero's headline as the page's heading" do
      assert_select_in alembic_hero_block(headline: "What is your business not seeing?"), "h1", text: "What is your business not seeing?"
    end

    private

    def assert_select_in(html, *selector, **equality)
      assert_select Nokogiri::HTML::DocumentFragment.parse(html), *selector, equality
    end
  end
end
