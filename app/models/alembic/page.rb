module Alembic
  class Page < ApplicationRecord
    validates :name, presence: true

    def add_block(block_type, x:, y:)
      update!(blocks: blocks + [ { "type" => block_type.key.to_s, "x" => x, "y" => y, "w" => block_type.width, "h" => block_type.height } ])
    end
  end
end
