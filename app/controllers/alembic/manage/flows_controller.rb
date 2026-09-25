module Alembic
  module Manage
    class FlowsController < EasyFlow::Manage::FlowsController
      hosted_by FLOW_HOST
      def edit
        super
        @summary = Flow::Summaries.new(@flow).text
      end

      def update
        summary = params.require(:flow)[:summary]
        Flow::Summaries.new(flow_host.flows.find(params[:id])).describe(summary) unless summary.nil?

        super
      end
    end
  end
end
