require "keystone_ui/react/mount_helper"
require "ks_blocks/content_helper"

module Alembic
  module Manage
    class BaseController < Alembic.base_controller.constantize
      include AuthenticatesAdmin
      include OwnedPages

      layout -> { Alembic.admin_layout }

      helper KeystoneUiHelper
      helper KeystoneUi::React::MountHelper
      helper KsBlocks::ContentHelper
      helper Alembic::PagesHelper
      helper Alembic::ResultBlocksHelper
      helper Alembic::ContentBlocksHelper
      helper_method :preview_values

      private

      def preview_values(page)
        @preview_values ||= Page::Preview.values_for(page, session.dig(:alembic_preview, page.id.to_s))
      end
    end
  end
end
