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

    def remove_block
      block_layout_record.remove_block(params[:block_id])
      head :no_content
    end

    def place_blocks
      block_layout_record.place_blocks(params.require(:layout).map { |position| position.permit(:id, :x, :y, :w, :h).to_h })
      head :no_content
    end
  end
end
