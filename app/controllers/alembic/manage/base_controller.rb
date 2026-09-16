require "keystone_ui/react/mount_helper"
require "ks_blocks/content_helper"

module Alembic
  module Manage
    class BaseController < Alembic.base_controller.constantize
      include AuthenticatesAdmin

      layout -> { Alembic.admin_layout }

      helper KeystoneUiHelper
      helper KeystoneUi::React::MountHelper
      helper KsBlocks::ContentHelper
    end
  end
end
