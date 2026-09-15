require "ks_blocks/layout"

module Alembic
  class Page < ApplicationRecord
    include KsBlocks::Layout

    block_layout :blocks

    validates :name, presence: true
  end
end
