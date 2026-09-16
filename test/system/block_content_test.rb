require "application_system_test_case"

module Alembic
  class BlockContentTest < ApplicationSystemTestCase
    test "selecting a block shows the fields its type has to fill in" do
      record = Page.create!(name: "Welcome")
      record.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :heading }, x: 0, y: 0)
      visit alembic.manage_page_path(record)

      find("[data-block]").click

      assert_selector "label", text: "Title"
    end
  end
end
