module Alembic
  module Manage
    class CategoriesController < BaseController
      def new
      end

      def create
        category = Category.create!(category_params)
        redirect_to manage_category_path(category)
      end

      private

      def category_params
        params.require(:category).permit(:name)
      end
    end
  end
end
