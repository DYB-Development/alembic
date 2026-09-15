require "application_system_test_case"

module Alembic
  class PageBuilderBlocksTest < ApplicationSystemTestCase
    test "the page builder lists the block types the host app registered" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))

      assert_selector "[data-block-type]", text: "Heading"
    end
  end
end
