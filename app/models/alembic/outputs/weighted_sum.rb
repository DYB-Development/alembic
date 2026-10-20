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
        run.state.sum { |id, value| weight_of(run.step(id), value) }
      end

      def self.weight_of(step, value)
        return picked_weight(step, value) if step["type"] == "multiple_select"
        return typed_weight(step, value) if step["type"] == "fill_in_the_blank"

        answer_weight(step, value)
      end

      def self.answer_weight(step, value)
        chosen = EasyFlow::Steps::Question.answers_of(step).find { |option| option.is_a?(Hash) && option["value"] == value }

        chosen&.fetch("weight", nil).to_i
      end

      def self.picked_weight(step, values)
        Array(values).sort == right_answers(step).sort ? 1 : 0
      end

      def self.typed_weight(step, text)
        Array(step["accepted_answers"]).any? { |accepted| comparable(accepted["value"]) == comparable(text) } ? 1 : 0
      end

      def self.comparable(text)
        text.to_s.strip.downcase
      end

      def self.right_answers(step)
        EasyFlow::Steps::Question.answers_of(step).filter_map { |option| option["value"] if option["weight"].to_i.positive? }
      end
    end
  end
end
