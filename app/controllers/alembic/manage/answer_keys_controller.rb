module Alembic
  module Manage
    class AnswerKeysController < PreviewsController
      helper_method :shows_answer_values?

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
        Flow::AnswerKey.chosen(step_settings(question.id))
      end

      def shows_answer_values?
        Flow::Summaries.new(previewed).shows_answer_values?
      end
    end
  end
end
