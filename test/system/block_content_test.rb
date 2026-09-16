require "application_system_test_case"
require "timeout"

module Alembic
  class BlockContentTest < ApplicationSystemTestCase
    test "content filled into a block's field is still there after a reload" do
      record = Page.create!(name: "Welcome")
      record.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :heading }, x: 0, y: 0)
      visit alembic.manage_page_path(record)
      find("[data-block]").click

      fill_in "Title", with: "Welcome aboard"
      find("[data-block-fields] input").send_keys(:tab)
      wait_until { record.reload.blocks.first["content"].present? }
      refresh
      find("[data-block]").click

      assert_equal "Welcome aboard", find("[data-block-fields] input").value
    end

    test "selecting a block shows the fields its type has to fill in" do
      record = Page.create!(name: "Welcome")
      record.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :heading }, x: 0, y: 0)
      visit alembic.manage_page_path(record)

      find("[data-block]").click

      assert_selector "label", text: "Title"
    end

    private

    def wait_until
      Timeout.timeout(Capybara.default_max_wait_time) { sleep 0.05 until yield }
    end
  end
end
