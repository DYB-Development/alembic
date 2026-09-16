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
      text = KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :text }
      record.add_block(text, x: 0, y: 0)
      record.add_block(text, x: 6, y: 0)

      visit "/pages/#{record.id}/shown"

      left, right = all("[data-block]").to_a
      assert_operator left.rect.y + left.rect.height, :<=, right.rect.y
    end
  end
end
