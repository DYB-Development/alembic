module Alembic
  module Summary
    Run = Data.define(:state, :steps, :run) do
      def initialize(state:, steps: {}, run: nil)
        super
      end

      def step(id)
        steps[id.to_s].to_h
      end
    end
  end
end
