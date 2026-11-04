module Alembic
  module Manage
    class QuizzesController < EasyFlow::Manage::BaseController
      hosted_by FLOW_HOST

      def new
        @flow = hosted_flows.new
      end
    end
  end
end
