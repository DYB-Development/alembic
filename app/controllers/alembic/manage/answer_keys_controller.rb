module Alembic
  module Manage
    class AnswerKeysController < PreviewsController
      helper_method :step_category, :shows_answer_values?

      def self.local_prefixes
        [ "alembic/flows", *super ]
      end

      private

      def flow_start_path(_slug)
        alembic.manage_flow_answer_key_path(previewed)
      end

      def flow_step_path(_slug)
        alembic.step_manage_flow_answer_key_path(previewed)
      end

      def chosen_answer(question)
        Flow::AnswerKey.chosen(@guide.step(question.id).config)
      end

      def shows_answer_values?
        Flow::Summaries.new(previewed).shows_answer_values?
      end

      def step_category(question)
        EasyFlow::Steps::Question.category_of(@guide.step(question.id)&.config)
      end
    end
  end
end
