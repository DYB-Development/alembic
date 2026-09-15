module Alembic
  module Manage
    class PageBlocksController < BaseController
      def create
        page = Page.find(params[:page_id])
        block_type = KsBlocks.registry.block_types.find { |registered| registered.key.to_s == params[:type] }

        page.add_block(block_type, x: params[:x], y: params[:y])
        head :no_content
      end

      def destroy
        Page.find(params[:page_id]).remove_block(params[:id])
        head :no_content
      end

      def place
        Page.find(params[:page_id]).place_blocks(params.require(:layout).map { |position| position.permit(:id, :x, :y, :w, :h).to_h })
        head :no_content
      end
    end
  end
end
