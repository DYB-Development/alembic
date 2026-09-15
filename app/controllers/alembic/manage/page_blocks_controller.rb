require "ks_blocks/layout_endpoints"

module Alembic
  module Manage
    class PageBlocksController < BaseController
      include KsBlocks::LayoutEndpoints

      private

      def block_layout_record
        Page.find(params[:page_id])
      end
    end
  end
end
