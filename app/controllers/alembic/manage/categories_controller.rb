module Alembic
  module Manage
    class CategoriesController < BaseController
      def index
        @categories = Category.order(:name)
      end

      def show
        @category = Category.find(params[:id])
      end

      def new
        @category = Category.new
      end

      def create
        @category = Category.new(category_params)
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
