module Alembic
  module Manage
    class QuestionsController < BaseController
      def create
        category = owned_categories.find(params[:category_id])
        written(category.questions, params.require(:question)).save!

        redirect_to manage_category_path(category)
      end

      private

      def written(questions, details)
        if details[:kind] == "multiple_choice"
          questions.choice_of(text: details[:text], labels: Array(details[:labels]), right: details[:right])
        else
          questions.true_or_false(text: details[:text], right: details[:right])
        end
      end
    end
  end
end
