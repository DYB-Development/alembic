require "application_system_test_case"
require "timeout"

module Alembic
  class PageBuilderBlocksTest < ApplicationSystemTestCase
    test "the page builder lists the block types the host app registered" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))

      open_block_list

      assert_selector "[data-block-type]", text: "Heading"
    end

    test "a block type added from the block list is on the grid and stays after a reload" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))

      add_block "heading"
      find("[data-block]", text: "Heading")
      refresh

      assert_selector "[data-block]", text: "Heading"
    end

    test "a block type dragged from the block list onto the grid is added to the page" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))

      open_block_list
      find("[data-block-type='heading']").drag_to(find("[data-block-grid] .react-grid-layout"))

      assert_selector "[data-block]", text: "Heading"
    end

    test "searching the block list leaves only the types whose names match" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))

      open_block_list
      fill_in "Search blocks", with: "Tex"

      assert_equal [ "text" ], all("[data-block-type]").map { |type| type["data-block-type"] }
    end

    test "the block types are offered in a dialog over the grid" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))

      open_block_list

      assert_selector "[data-blocks-dialog][open] [data-block-type]", text: "Heading"
    end

    test "a block dragged onto the row above it takes that place after a reload" do
      record = Page.create!(name: "Welcome")
      record.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :heading }, x: 0, y: 0)
      record.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :text }, x: 0, y: 1)
      visit alembic.manage_page_path(record)
      start_editing

      text, heading = find("[data-block]", text: "Text"), find("[data-block]", text: "Heading")
      page.driver.browser.action.click_and_hold(text.native).move_to(heading.native, 0, -20).release.perform
      wait_until { record.reload.blocks.find { |block| block["type"] == "text" }["y"].zero? }
      refresh

      assert_operator find("[data-block]", text: "Text").rect.y, :<, find("[data-block]", text: "Heading").rect.y
    end

    test "a block widened by dragging its corner keeps its new size after a reload" do
      record = Page.create!(name: "Welcome")
      record.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :text }, x: 0, y: 0)
      visit alembic.manage_page_path(record)
      start_editing
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
      record.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :heading }, x: 0, y: 0)
      visit alembic.manage_page_path(record)
      start_editing

      drag_to_remove find("[data-block]", text: "Heading")
      wait_until { record.reload.blocks.empty? }
      refresh

      assert_no_selector "[data-block]"
    end

    test "a move made in a tab showing an out-of-date grid is refused rather than applied" do
      record = Page.create!(name: "Welcome")
      record.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :heading }, x: 0, y: 0)
      record.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :text }, x: 0, y: 1)
      visit alembic.manage_page_path(record)
      start_editing
      stale_tab = open_new_window
      within_window(stale_tab) do
        visit alembic.manage_page_path(record)
        start_editing
      end

      text, heading = find("[data-block]", text: "Text"), find("[data-block]", text: "Heading")
      page.driver.browser.action.click_and_hold(text.native).move_to(heading.native, 0, -20).release.perform
      wait_until { record.reload.blocks.find { |block| block["type"] == "text" }["y"].zero? }
      moved = record.reload.blocks

      within_window(stale_tab) do
        stale_text = find("[data-block]", text: "Text")
        page.driver.browser.action.click_and_hold(stale_text.native).move_by(600, 0).release.perform
        find("[role=alert]", text: "changed")
      end

      assert_equal moved, record.reload.blocks
    end

    private

    def start_editing
      click_on "Edit"
    end

    def open_block_list
      start_editing
      click_on "Add a block"
    end

    def add_block(key)
      open_block_list
      within("[data-block-type='#{key}']") { click_on "Add" }
    end

    def drag_to_remove(block)
      page.driver.browser.action.click_and_hold(block.native).move_to(find("[data-remove-target]").native).release.perform
    end

    def wait_until
      Timeout.timeout(Capybara.default_max_wait_time) { sleep 0.05 until yield }
    end
  end
end
