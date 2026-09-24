module Alembic
  module Manage
    class PreviewsController < EasyFlow::Manage::PreviewsController
      include Summarizes

      def show
        @flow = previewed
        render template: "alembic/flows/show"
      end

      private

      def flow_start_path(_slug)
        alembic.manage_flow_preview_path(previewed)
      end

      def flow_step_path(_slug)
        alembic.step_manage_flow_preview_path(previewed)
      end
    end
  end
end
