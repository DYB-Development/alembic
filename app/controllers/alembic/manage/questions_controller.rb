module Alembic
  module Manage
    class QuestionsController < BaseController
      before_action :find_category

      def new
        @question = @category.questions.new(kind: params[:kind] == "multiple_choice" ? :multiple_choice : :true_false)
      end

      def create
        @question = written(@category.questions, params.require(:question))
        return render :new, status: :unprocessable_content unless @question.save

        redirect_to manage_category_path(@category)
      end

      private

      def find_category
        @category = owned_categories.find(params[:category_id])
      end

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
