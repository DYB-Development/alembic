module Alembic
  module Manage
    class PagesController < BaseController
      def index
        @pages = Page.order(:name)
      end
    end
  end
end
