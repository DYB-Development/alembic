require "application_system_test_case"

module Alembic
  class PageBuilderBlocksTest < ApplicationSystemTestCase
    test "the page builder lists the block types the host app registered" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))

      assert_selector "[data-block-type]", text: "Heading"
    end

    test "a block type added from the block list is on the grid and stays after a reload" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))

      within("[data-block-type='heading']") { click_on "Add" }
      find("[data-block]", text: "Heading")
      refresh

      assert_selector "[data-block]", text: "Heading"
    end
  end
end
