module Alembic
  module Manage
    class PagesController < BaseController
      def index
        @pages = Page.order(:name)
      end

      def create
        Page.create!(page_params)
        redirect_to manage_pages_path
      end

      private

      def page_params
        params.require(:page).permit(:name)
      end
    end
  end
end
