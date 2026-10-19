module Alembic
  module Manage
    class CategoriesController < BaseController
      def index
        @categories = owned_categories.order(:name)
      end

      def show
        @category = owned_categories.find(params[:id])
      end

      def new
        @category = Category.new
      end

      def create
        @category = owned_categories.new(category_params)
        return render :new, status: :unprocessable_content unless @category.save

        redirect_to manage_category_path(@category)
      end

      private

      def category_params
        params.require(:category).permit(:name)
      end
    end
  end
end
