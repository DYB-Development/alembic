require "ks_blocks/block_type"

module KsBlocks
  module Grid
    module_function

    def add(blocks, block_type, x:, y:)
      blocks + [ { "type" => block_type.key.to_s, "x" => x, "y" => y, "w" => block_type.width, "h" => block_type.height } ]
    end
  end
end
