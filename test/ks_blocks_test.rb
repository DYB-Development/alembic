require "test_helper"
require "ks_blocks"

class KsBlocksTest < ActiveSupport::TestCase
  test "declaring a block type puts it in the default registry" do
    KsBlocks.block(:ks_blocks_probe, name: "Probe", width: 4, height: 2)

    assert_includes KsBlocks.registry.block_types, KsBlocks::BlockType.new(key: :ks_blocks_probe, name: "Probe", width: 4, height: 2)
  end

  test "layout data carries the blocks it is given" do
    blocks = [ { "id" => "b1", "type" => "text", "x" => 0, "y" => 0, "w" => 6, "h" => 2 } ]

    assert_equal blocks, KsBlocks.layout_data(blocks)[:blocks]
  end

  test "layout data lists each registered block type's key, name and starting size" do
    KsBlocks.block(:layout_data_probe, name: "Layout probe", width: 3, height: 1)

    assert_includes KsBlocks.layout_data([])[:block_types], { key: :layout_data_probe, name: "Layout probe", width: 3, height: 1 }
  end
end
