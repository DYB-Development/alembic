require "application_system_test_case"

module Alembic
  class DrawnBlockTest < ApplicationSystemTestCase
    test "filling in a block's field redraws its component without a reload" do
      record = Page.create!(name: "Welcome")
      record.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :section }, x: 0, y: 0)
      visit alembic.manage_page_path(record)
      find("[data-block]").click

      fill_in "Title", with: "Our team"
      find_field("Title").send_keys(:tab)

      assert_selector "[data-block-content] h2", text: "Our team"
    end
  end
end
