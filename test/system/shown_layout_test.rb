require "application_system_test_case"

module Alembic
  class ShownLayoutTest < ApplicationSystemTestCase
    setup do
      page.driver.browser.manage.window.resize_to(400, 900)
    end

    teardown do
      page.driver.browser.manage.window.resize_to(1400, 1000)
    end

    test "a shown layout stacks its blocks on a phone" do
      record = Page.create!(name: "Welcome")
      note = KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :note }
      record.add_block(note, x: 0, y: 0)
      record.add_block(note, x: 6, y: 0)
      record.reload.blocks.each { |block| record.fill_block(block["id"], { "title" => "Note" }) }
      record.reload.publish

      visit "/pages/#{record.id}/shown"

      left, right = all("[data-block]").to_a
      assert_operator left.rect.y + left.rect.height, :<=, right.rect.y
    end
  end
end
