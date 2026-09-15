require "test_helper"
require "ks_blocks"

class KsBlocksTest < ActiveSupport::TestCase
  test "declaring a block type puts it in the default registry" do
    KsBlocks.block(:ks_blocks_probe, name: "Probe", width: 4, height: 2)

    assert_includes KsBlocks.registry.block_types, KsBlocks::BlockType.new(key: :ks_blocks_probe, name: "Probe", width: 4, height: 2)
  end
end
