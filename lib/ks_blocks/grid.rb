require "securerandom"
require "ks_blocks/block_type"
require "ks_blocks"

module KsBlocks
  class InvalidLayout < StandardError; end

  module Grid
    COLUMNS = 12
    ROW_HEIGHT = 60
    GAP = 10

    module_function

    def add(blocks, block_type, x: nil, y: nil, columns: COLUMNS)
      x, y = first_open_place(blocks, block_type, columns) if x.nil? || y.nil?
      added = { "id" => SecureRandom.uuid, "type" => block_type.key.to_s, "x" => x, "y" => y, "w" => block_type.width, "h" => block_type.height }
      (blocks + [ added ]).tap { |arranged| refuse_unfit(arranged, [ added["id"] ], columns) }
    end

    def place(blocks, positions, columns: COLUMNS)
      placed = positions.index_by { |position| position["id"] }
      blocks.map { |block| block.merge(placed.fetch(block["id"], {}).slice("x", "y", "w", "h")) }.tap { |arranged| refuse_unfit(arranged, placed.keys, columns) }
    end

    def refuse_unfit(blocks, moved_ids, columns)
      blocks.select { |block| moved_ids.include?(block["id"]) }.each do |moved|
        raise InvalidLayout, "#{named(moved)} must be at least one column wide and one row tall" if moved["w"] < 1 || moved["h"] < 1
        raise InvalidLayout, "#{named(moved)} runs past the grid's last column" if moved["x"] + moved["w"] > columns
      end
      refuse_overlaps(blocks, moved_ids)
    end

    def refuse_overlaps(blocks, moved_ids)
      blocks.select { |block| moved_ids.include?(block["id"]) }.each do |moved|
        covered = blocks.find { |other| other["id"] != moved["id"] && overlaps?(other, moved["x"], moved["y"], moved["w"], moved["h"]) }
        raise InvalidLayout, "#{named(moved)} overlaps #{named(covered)}" if covered
      end
    end

    def named(block)
      KsBlocks.registry.block_types.find { |block_type| block_type.key.to_s == block["type"] }&.name || block["type"]
    end

    def remove(blocks, id)
      blocks.reject { |block| block["id"] == id }
    end

    def first_open_place(blocks, block_type, columns)
      (0..).each do |y|
        (0..columns - block_type.width).each do |x|
          return [ x, y ] unless blocks.any? { |block| overlaps?(block, x, y, block_type.width, block_type.height) }
        end
      end
    end

    def overlaps?(block, x, y, width, height)
      x < block["x"] + block["w"] && block["x"] < x + width && y < block["y"] + block["h"] && block["y"] < y + height
    end
  end
end
