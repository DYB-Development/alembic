module Alembic
  module Manage
    class QuestionsController < BaseController
      def create
        category = owned_categories.find(params[:category_id])
        details = params.require(:question)
        category.questions.true_or_false(text: details[:text], right: details[:right]).save!

        redirect_to manage_category_path(category)
      end
    end
  end
end
