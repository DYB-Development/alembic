module Alembic
  module Manage
    class QuizzesController < EasyFlow::Manage::BaseController
      hosted_by FLOW_HOST

      def new
        @flow = hosted_flows.new
      end

      def create
        @flow = hosted_flows.new(params.require(:quiz).permit(:title))
        Flow::TitledStart.new(@flow).save
        redirect_to easy_flow.manage_flow_path(@flow), notice: "Quiz created."
      end
    end
  end
end
