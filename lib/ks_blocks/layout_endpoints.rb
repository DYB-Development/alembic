require "active_support/concern"
require "ks_blocks"

module KsBlocks
  module LayoutEndpoints
    extend ActiveSupport::Concern

    def add_block
      block_type = KsBlocks.registry.block_types.find { |registered| registered.key.to_s == params[:type] }

      block_layout_record.add_block(block_type, x: params[:x], y: params[:y])
      head :no_content
    end
  end
end
