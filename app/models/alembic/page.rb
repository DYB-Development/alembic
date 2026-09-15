require "securerandom"

module Alembic
  class Page < ApplicationRecord
    validates :name, presence: true

    def add_block(block_type, x: first_open_column, y: 0)
      block = { "id" => SecureRandom.uuid, "type" => block_type.key.to_s, "x" => x, "y" => y, "w" => block_type.width, "h" => block_type.height }
      update!(blocks: blocks + [ block ])
    end

    private

    def first_open_column
      blocks.map { |block| block["x"] + block["w"] }.max || 0
    end
  end
end
