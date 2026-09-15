require "securerandom"

module Alembic
  class Page < ApplicationRecord
    COLUMNS = 12

    validates :name, presence: true

    def add_block(block_type, x: nil, y: nil)
      x, y = first_open_place(block_type) if x.nil? || y.nil?
      block = { "id" => SecureRandom.uuid, "type" => block_type.key.to_s, "x" => x, "y" => y, "w" => block_type.width, "h" => block_type.height }
      update!(blocks: blocks + [ block ])
    end

    private

    def first_open_place(block_type)
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
