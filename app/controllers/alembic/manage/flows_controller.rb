module Alembic
  module Manage
    class FlowsController < EasyFlow::Manage::FlowsController
      def edit
        super
        @summary = Flow::Summaries.new(@flow).text
      end

      def update
        summary = params.require(:flow)[:summary]
        Flow::Summaries.new(EasyFlow::Definition.find(params[:id])).describe(summary) unless summary.nil?

        super
      end
    end
  end
end
