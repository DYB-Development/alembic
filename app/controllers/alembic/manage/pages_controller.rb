module Alembic
  module Manage
    class PagesController < BaseController
      def index
        @pages = Page.order(:name)
      end

      def show
        @page = Page.find(params[:id])
        @payload = payload(@page)

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
          name: page.name
        }.merge(page.layout_data)
      end

      def page_params
        params.require(:page).permit(:name)
      end
    end
  end
end
