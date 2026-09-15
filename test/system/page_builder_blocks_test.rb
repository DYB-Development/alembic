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

      find("[data-block-type='heading']").drag_to(find("[data-block-grid] .react-grid-layout"))

      assert_selector "[data-block]", text: "Heading"
    end

    test "on a wide screen the block types sit beside the grid" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))
      list_right = page.evaluate_script("document.querySelector('[data-block-type]').getBoundingClientRect().right")

      assert_operator list_right, :<=, page.evaluate_script("document.querySelector('[data-block-grid]').getBoundingClientRect().left")
    end

    test "a block dragged onto the row above it takes that place after a reload" do
      record = Page.create!(name: "Welcome")
      record.add_block(KsBlocks.registry.block_types.find { |type| type.key == :heading }, x: 0, y: 0)
      record.add_block(KsBlocks.registry.block_types.find { |type| type.key == :text }, x: 0, y: 1)
      visit alembic.manage_page_path(record)

      text, heading = find("[data-block]", text: "Text"), find("[data-block]", text: "Heading")
      page.driver.browser.action.click_and_hold(text.native).move_to(heading.native, 0, -20).release.perform
      wait_until { record.reload.blocks.find { |block| block["type"] == "text" }["y"].zero? }
      refresh

      assert_operator find("[data-block]", text: "Text").rect.y, :<, find("[data-block]", text: "Heading").rect.y
    end

    test "a block widened by dragging its corner keeps its new size after a reload" do
      record = Page.create!(name: "Welcome")
      record.add_block(KsBlocks.registry.block_types.find { |type| type.key == :text }, x: 0, y: 0)
      visit alembic.manage_page_path(record)
      block = find("[data-block]", text: "Text")
      width_before = block.rect.width

      handle = block.find(".react-resizable-handle-se", visible: :all)
      page.driver.browser.action.move_to(block.native).move_to(handle.native).pointer_down(:left).move_by(20, 0).move_by(100, 0).move_by(180, 0).pointer_up(:left).perform
      wait_until { record.reload.blocks.first["w"] > 6 }
      refresh

      assert_operator find("[data-block]", text: "Text").rect.width, :>, width_before
    end

    test "a removed block is still gone after a reload" do
      record = Page.create!(name: "Welcome")
      record.add_block(KsBlocks.registry.block_types.find { |type| type.key == :heading }, x: 0, y: 0)
      visit alembic.manage_page_path(record)

      within(find("[data-block]", text: "Heading")) { click_on "Remove" }
      wait_until { record.reload.blocks.empty? }
      refresh

      assert_no_selector "[data-block]"
    end

    private

    def wait_until
      Timeout.timeout(Capybara.default_max_wait_time) { sleep 0.05 until yield }
    end
  end
end
