module Alembic
  class ApplicationController < Alembic.base_controller.constantize
    layout -> { Alembic.layout }
    helper KeystoneUiHelper

    rescue_from NotPublished, NotPermitted, Withdrawn, with: :refuse

    private

    def refuse(refusal)
      return head :not_found unless Alembic.refusal_method

      send(Alembic.refusal_method, refusal)
    end
  end
end
