module Alembic
  module Manage
    class PagesController < BaseController
      def index
        @pages = owned_pages.order(:name)
      end

      def show
        @page = owned_pages.find(params[:id])
        @payload = payload(@page)

        respond_to do |format|
          format.html
          format.json { render json: @payload }
        end
      end

      def create
        page = owned_pages.create!(page_params)
        redirect_to manage_page_path(page)
      end

      def publish
        page = owned_pages.find(params[:id])
        page.publish

        redirect_to manage_page_path(page)
      end

      def preview
        page = owned_pages.find(params[:id])
        session[:alembic_preview] = session.fetch(:alembic_preview, {}).merge(page.id.to_s => params[:choice].presence)

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
        params.require(:page).permit(:name, :slug)
      end
    end
  end
end
