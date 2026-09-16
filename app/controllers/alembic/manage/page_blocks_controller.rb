require "ks_blocks/layout_endpoints"

module Alembic
  module Manage
    class PageBlocksController < BaseController
      include KsBlocks::LayoutEndpoints

      private

      def block_layout_record
        Page.find(params[:page_id])
      end

      def block_content(block)
        render_to_string(partial: "alembic/manage/pages/block_content", locals: { block: block }, formats: [ :html ])
      end
    end
  end
end
