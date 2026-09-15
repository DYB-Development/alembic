module Alembic
  module Manage
    class PageBlocksController < BaseController
      def create
        page = Page.find(params[:page_id])
        block_type = Pages.registry.block_types.find { |registered| registered.key.to_s == params[:type] }

        page.add_block(block_type, x: params[:x], y: params[:y])
        head :no_content
      end
    end
  end
end
