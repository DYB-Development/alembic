module Alembic
  module Manage
    class FlowsController < EasyFlow::Manage::FlowsController
      def edit
        super
        @summary = Flow::Summaries.new(@flow).text
      end
    end
  end
end
