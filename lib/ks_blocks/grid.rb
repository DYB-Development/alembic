require "securerandom"
require "ks_blocks/block_type"

module KsBlocks
  module Grid
    module_function

    def add(blocks, block_type, x: blocks.map { |block| block["x"] + block["w"] }.max || 0, y: 0)
      blocks + [ { "id" => SecureRandom.uuid, "type" => block_type.key.to_s, "x" => x, "y" => y, "w" => block_type.width, "h" => block_type.height } ]
    end
  end
end
