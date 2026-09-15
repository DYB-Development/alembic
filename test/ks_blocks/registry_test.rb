require "test_helper"
require "ks_blocks/registry"

module KsBlocks
  class RegistryTest < ActiveSupport::TestCase
    test "registering a block type makes it findable by its key" do
      registry = Registry.new
      registry.register(BlockType.new(key: :heading, name: "Heading", width: 12, height: 1))

      assert_equal [ :heading ], registry.block_types.map(&:key)
    end
  end
end
