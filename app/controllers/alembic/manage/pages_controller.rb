module Alembic
  module Manage
    class PagesController < BaseController
      def index
        @pages = Page.order(:name)
      end

      def show
        @payload = payload(Page.find(params[:id]))

        respond_to do |format|
          format.html
          format.json { render json: @payload }
        end
      end

      def create
        page = Page.create!(page_params)
        redirect_to manage_page_path(page)
      end

      private

      def payload(page)
        {
          base: manage_page_path(page),
          pages: manage_pages_path,
          name: page.name,
          block_types: KsBlocks.registry.block_types.map(&:to_h),
          blocks: page.blocks
        }
      end

      def page_params
        params.require(:page).permit(:name)
      end
    end
  end
end
