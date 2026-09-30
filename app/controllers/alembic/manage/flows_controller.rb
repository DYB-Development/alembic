module Alembic
  module Manage
    class FlowsController < EasyFlow::Manage::FlowsController
      hosted_by FLOW_HOST
      def edit
        super
        summaries = Flow::Summaries.new(@flow)
        @summary = summaries.text
        @summary_page = summaries.summary_page
        @shows_answer_values = summaries.shows_answer_values?
        @published_pages = Page.where(id: Page::Version.live.select(:page_id)).order(:name)
      end

      def update
        details = params.require(:flow)
        summaries = Flow::Summaries.new(flow_host.flows.find(params[:id]))
        summaries.describe(details[:summary]) unless details[:summary].nil?
        summaries.finish_on(Page.find_by(id: details[:summary_page_id])) unless details[:summary_page_id].nil?
        summaries.show_answer_values(details[:shows_answer_values] == "1") unless details[:shows_answer_values].nil?

        super
      end
    end
  end
end
