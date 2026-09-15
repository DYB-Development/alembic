require "test_helper"
require "ks_blocks/layout"

module KsBlocks
  class LayoutTest < ActiveSupport::TestCase
    class Host < ActiveRecord::Base
      self.table_name = "alembic_pages"
      include KsBlocks::Layout
      block_layout :blocks
    end

    TEXT = BlockType.new(key: :text, name: "Text", width: 6, height: 2)

    test "a host record saves a block added to its layout column" do
      host = Host.create!(name: "Dashboard")

      host.add_block(TEXT, x: 0, y: 1)

      assert_equal [ [ "text", 0, 1 ] ], host.reload.blocks.map { |block| block.values_at("type", "x", "y") }
    end
  end
end
