module Alembic
  module Manage
    class BaseController < Alembic.base_controller.constantize
      include AuthenticatesAdmin

      layout -> { Alembic.admin_layout }

      helper KeystoneUiHelper
      helper KeystoneUi::React::MountHelper
    end
  end
end
