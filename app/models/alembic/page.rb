require "securerandom"

module Alembic
  class Page < ApplicationRecord
    validates :name, presence: true

    def add_block(block_type, x:, y:)
      block = { "id" => SecureRandom.uuid, "type" => block_type.key.to_s, "x" => x, "y" => y, "w" => block_type.width, "h" => block_type.height }
      update!(blocks: blocks + [ block ])
    end
  end
end
