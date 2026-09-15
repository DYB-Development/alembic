require "active_support/concern"
require "ks_blocks/grid"

module KsBlocks
  module Layout
    extend ActiveSupport::Concern

    class_methods do
      def block_layout(column)
        define_method(:add_block) do |block_type, x: nil, y: nil|
          update!(column => Grid.add(public_send(column), block_type, x: x, y: y))
        end
      end
    end
  end
end
