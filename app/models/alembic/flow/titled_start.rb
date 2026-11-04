module Alembic
  module Flow
    class TitledStart
      def initialize(flow)
        @flow = flow
      end

      def save
        @flow.slug = @flow.title.parameterize
        @flow.save
      end
    end
  end
end
