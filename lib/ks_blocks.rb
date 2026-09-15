require "ks_blocks/registry"

module KsBlocks
  class << self
    def block(key, name:, width:, height:)
      registry.register(BlockType.new(key: key, name: name, width: width, height: height))
    end

    def layout_data(blocks)
      { block_types: registry.block_types.map(&:to_h), blocks: blocks }
    end

    def registry
      @registry ||= Registry.new
    end
  end
end
