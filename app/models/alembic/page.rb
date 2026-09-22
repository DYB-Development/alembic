require "ks_blocks/layout"

module Alembic
  class Page < ApplicationRecord
    include KsBlocks::Layout

    block_layout :blocks, kind: :pages

    validates :name, presence: true

    def self.block(key, drawn_by: nil, options: {}, body: nil, **block_type)
      Drawing.record(key, drawn_by)
      Options.declare(key, options, body: body)
      KsBlocks.block(key, kind: :pages, **block_type)
    end
  end
end
