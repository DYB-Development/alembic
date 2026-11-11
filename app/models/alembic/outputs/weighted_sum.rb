module Alembic
  module Outputs
    module WeightedSum
      def self.output_type
        Summary::OutputType.define(:weighted_sum) do
          label "Score"
          compute { |_config, run, _so_far| WeightedSum.total(run) }
        end
      end

      def self.register(registry = Summary.registry)
        registry.register(output_type)
      end

      def self.total(run)
        QuestionKit::Score.total(run.state, run.steps)
      end

      def self.weight_of(step, value)
        QuestionKit::Score.worth(step, value)
      end

      def self.right_answers(step)
        QuestionKit::Score.right_answers(step)
      end
    end
  end
end
