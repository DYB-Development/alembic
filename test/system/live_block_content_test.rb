require "application_system_test_case"

module Alembic
  class LiveBlockContentTest < ApplicationSystemTestCase
    test "the content the host renders for a block is inside that block on the grid" do
      record = Page.create!(name: "Welcome")
      record.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :heading }, x: 0, y: 0)

      visit alembic.manage_page_path(record)

      assert_selector "[data-block] [data-block-content]", text: "Heading"
    end
  end
end
