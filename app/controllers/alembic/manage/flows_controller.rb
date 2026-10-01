module Alembic
  module Manage
    class FlowsController < EasyFlow::Manage::FlowsController
      hosted_by FLOW_HOST
      def edit
        super
        summaries = Flow::Summaries.new(@flow)
        @summary = summaries.text
        @summary_page = summaries.summary_page
        @intro_page = summaries.intro_page
        @outputs = Array(summaries.document.to_h["outputs"])
        @shows_answer_values = summaries.shows_answer_values?
        @asks_on_one_page = summaries.asks_on_one_page?
        @branches = summaries.branches?
        @published_pages = Page.where(id: Page::Version.live.select(:page_id)).order(:name)
      end

      def update
        details = params.require(:flow)
        summaries = Flow::Summaries.new(flow_host.flows.find(params[:id]))
        summaries.describe(details[:summary]) unless details[:summary].nil?
        summaries.start_on(Page.find_by(id: details[:intro_page_id])) unless details[:intro_page_id].nil?
        summaries.finish_on(Page.find_by(id: details[:summary_page_id])) unless details[:summary_page_id].nil?
        summaries.show_answer_values(details[:shows_answer_values] == "1") unless details[:shows_answer_values].nil?
        summaries.ask_on_one_page(details[:asks_on_one_page] == "1") unless details[:asks_on_one_page].nil?
        record_outputs(summaries, details[:outputs]) if details[:outputs]

        super
      end

      private

      def record_outputs(summaries, submitted)
        current = Array(summaries.document.to_h["outputs"])
        edited = submitted.permit!.to_h.sort_by { |index, _| index.to_i }.map do |index, output|
          current.fetch(index.to_i, {}).merge(output).merge(listed_bands(output))
        end
        summaries.record(summaries.document.to_h.merge("outputs" => edited))
      end

      def listed_bands(output)
        return {} unless output["bands"].is_a?(Hash)

        bands = output["bands"].sort_by { |position, _| position.to_i }.map do |_position, band|
          band.merge("ceiling" => band["ceiling"].presence&.to_i)
        end
        { "bands" => bands }
      end
    end
  end
end
