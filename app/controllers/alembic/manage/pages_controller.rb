module Alembic
  module Manage
    class PagesController < BaseController
      def index
        @pages = Page.order(:name)
      end

      def show
        @page = Page.find(params[:id])
      end

      def create
        page = Page.create!(page_params)
        redirect_to manage_page_path(page)
      end

      private

      def page_params
        params.require(:page).permit(:name)
      end
    end
  end
end
