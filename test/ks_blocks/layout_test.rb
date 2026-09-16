require "test_helper"
require "ks_blocks/layout"

module KsBlocks
  class LayoutTest < ActiveSupport::TestCase
    class Host < ActiveRecord::Base
      self.table_name = "alembic_pages"
      include KsBlocks::Layout
      block_layout :blocks, kind: :dashboards
    end

    class NarrowHost < ActiveRecord::Base
      self.table_name = "alembic_pages"
      include KsBlocks::Layout
      block_layout :blocks, columns: 6
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

    test "a host record's layout data carries its own blocks" do
      host = Host.create!(name: "Dashboard")
      host.add_block(TEXT, x: 0, y: 0)

      assert_equal host.blocks, host.layout_data[:blocks]
    end

    test "a host record refuses to place blocks against a layout version it no longer has" do
      host = Host.create!(name: "Dashboard")
      host.add_block(TEXT, x: 0, y: 0)
      drawn = host.layout_data[:version]
      host.add_block(TEXT, x: 6, y: 0)

      assert_raises(InvalidLayout) { host.place_blocks([ { "id" => host.blocks.first["id"], "x" => 0, "y" => 2, "w" => 6, "h" => 2 } ], version: drawn) }
    end

    test "a host record's layout data lists only its own kind of block types" do
      KsBlocks.block(:page_only_probe, name: "Page only", width: 3, height: 1, kind: :pages)
      host = Host.create!(name: "Dashboard")

      assert_equal [], host.layout_data[:block_types].select { |block_type| block_type[:key] == :page_only_probe }
    end

    test "a host record with a narrower grid refuses a block that runs past its last column" do
      host = NarrowHost.create!(name: "Narrow")
      host.add_block(TEXT, x: 0, y: 0)

      assert_raises(InvalidLayout) { host.place_blocks([ { "id" => host.blocks.first["id"], "x" => 2, "y" => 0, "w" => 6, "h" => 2 } ]) }
    end
  end
end
