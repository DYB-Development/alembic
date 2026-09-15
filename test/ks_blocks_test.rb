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
end
