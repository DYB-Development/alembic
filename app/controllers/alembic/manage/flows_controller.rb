module Alembic
  module Manage
    class FlowsController < EasyFlow::Manage::FlowsController
      hosted_by FLOW_HOST
      def edit
        super
        @summary = Flow::Summaries.new(@flow).text
      end

      def update
        details = params.require(:flow)
        summaries = Flow::Summaries.new(flow_host.flows.find(params[:id]))
        summaries.describe(details[:summary]) unless details[:summary].nil?
        summaries.finish_on(Page.find_by(id: details[:summary_page_id])) unless details[:summary_page_id].nil?

        super
      end
    end
  end
end
