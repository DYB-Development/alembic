require "securerandom"
require "ks_blocks/block_type"

module KsBlocks
  module Grid
    COLUMNS = 12

    module_function

    def add(blocks, block_type, x: nil, y: nil)
      x, y = first_open_place(blocks, block_type) if x.nil? || y.nil?
      blocks + [ { "id" => SecureRandom.uuid, "type" => block_type.key.to_s, "x" => x, "y" => y, "w" => block_type.width, "h" => block_type.height } ]
    end

    def place(blocks, positions)
      placed = positions.index_by { |position| position["id"] }
      blocks.map { |block| block.merge(placed.fetch(block["id"], {}).slice("x", "y", "w", "h")) }
    end

    def remove(blocks, id)
      blocks.reject { |block| block["id"] == id }
    end

    def first_open_place(blocks, block_type)
      (0..).each do |y|
        (0..COLUMNS - block_type.width).each do |x|
          return [ x, y ] unless blocks.any? { |block| overlaps?(block, x, y, block_type.width, block_type.height) }
        end
      end
    end

    def overlaps?(block, x, y, width, height)
      x < block["x"] + block["w"] && block["x"] < x + width && y < block["y"] + block["h"] && block["y"] < y + height
    end
  end
end
