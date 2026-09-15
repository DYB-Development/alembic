require "application_system_test_case"
require "timeout"

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

    test "a block dragged onto the row above it takes that place after a reload" do
      record = Page.create!(name: "Welcome")
      record.add_block(Pages.registry.block_types.find { |type| type.key == :heading }, x: 0, y: 0)
      record.add_block(Pages.registry.block_types.find { |type| type.key == :text }, x: 0, y: 1)
      visit alembic.manage_page_path(record)

      text, heading = find("[data-block]", text: "Text"), find("[data-block]", text: "Heading")
      page.driver.browser.action.click_and_hold(text.native).move_to(heading.native, 0, -20).release.perform
      wait_until { record.reload.blocks.find { |block| block["type"] == "text" }["y"].zero? }
      refresh

      assert_operator find("[data-block]", text: "Text").rect.y, :<, find("[data-block]", text: "Heading").rect.y
    end

    private

    def wait_until
      Timeout.timeout(Capybara.default_max_wait_time) { sleep 0.05 until yield }
    end
  end
end
