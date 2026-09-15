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

    test "a block type dragged from the block list onto the grid is added to the page" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))

      find("[data-block-type='heading']").drag_to(find("[data-page-grid] .react-grid-layout"))

      assert_selector "[data-block]", text: "Heading"
    end

    test "on a wide screen the block types sit beside the grid" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))
      list_right = page.evaluate_script("document.querySelector('[data-block-type]').getBoundingClientRect().right")

      assert_operator list_right, :<=, page.evaluate_script("document.querySelector('[data-page-grid]').getBoundingClientRect().left")
    end
  end
end
