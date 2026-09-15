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

    test "a host record saves the positions and sizes its blocks are placed at" do
      host = Host.create!(name: "Dashboard")
      host.add_block(TEXT, x: 0, y: 0)

      host.place_blocks([ { "id" => host.blocks.first["id"], "x" => 6, "y" => 2, "w" => 4, "h" => 1 } ])

      assert_equal [ 6, 2, 4, 1 ], host.reload.blocks.first.values_at("x", "y", "w", "h")
    end

    test "a host record saves its layout without a removed block" do
      host = Host.create!(name: "Dashboard")
      host.add_block(TEXT, x: 0, y: 0)

      host.remove_block(host.blocks.first["id"])

      assert_empty host.reload.blocks
    end
  end
end
