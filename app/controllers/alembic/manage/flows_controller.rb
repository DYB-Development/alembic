module Alembic
  module Manage
    class FlowsController < EasyFlow::Manage::FlowsController
      hosted_by FLOW_HOST
      include OwnedPages
      helper Alembic::ApplicationHelper
      def edit
        super
        summaries = Flow::Summaries.new(@flow)
        @summary = summaries.text
        @summary_page = summaries.summary_page
        @intro_page = summaries.intro_page
        @outputs = Array(summaries.document.to_h["outputs"])
        @uncategorised = scored_by_category?(@outputs) ? questions_of(@flow).reject { |node| EasyFlow::Steps::Question.category_of(node).present? } : []
        @categories = questions_of(@flow).filter_map { |node| EasyFlow::Steps::Question.category_of(node) }.uniq
        @shows_answer_values = summaries.shows_answer_values?
        @asks_on_one_page = summaries.asks_on_one_page?
        @branches = summaries.branches?
        @published_pages = owned_pages.where(id: Page::Version.live.select(:page_id)).order(:name)
      end

      def update
        details = params.require(:flow)
        summaries = Flow::Summaries.new(flow_host.flows.find(params[:id]))
        summaries.describe(details[:summary]) unless details[:summary].nil?
        summaries.start_on(owned_pages.find_by(id: details[:intro_page_id])) unless details[:intro_page_id].nil?
        summaries.finish_on(owned_pages.find_by(id: details[:summary_page_id])) unless details[:summary_page_id].nil?
        summaries.show_answer_values(details[:shows_answer_values] == "1") unless details[:shows_answer_values].nil?
        summaries.ask_on_one_page(details[:asks_on_one_page] == "1") unless details[:asks_on_one_page].nil?
        record_outputs(summaries, details[:outputs]) if details[:outputs]

        super
      rescue Summary::UnknownOutputType => refused
        redirect_to easy_flow.edit_manage_flow_path(params[:id]), alert: refused.message
      end

      private

      def scored_by_category?(outputs)
        outputs.any? { |output| %w[grouped lowest].include?(output["type"]) }
      end

      def questions_of(flow)
        Array(flow.definition.to_h["nodes"]).select { |node| node["type"] == "question" }
      end

      def record_outputs(summaries, submitted)
        edited = Flow::OutputForm.edited(Array(summaries.document.to_h["outputs"]), submitted.permit!.to_h)
        summaries.record(summaries.document.to_h.merge("outputs" => edited))
      end
    end
  end
end
