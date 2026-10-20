module Alembic
  module Flow
    class UploadedQuestions
      def initialize(flow)
        @flow = flow
      end

      def new(values)
        UploadedQuestion.new(values.merge(flow: @flow))
      end

      def where(*)
        []
      end
    end
  end
end
