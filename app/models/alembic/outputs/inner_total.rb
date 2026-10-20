module Alembic
  module Outputs
    module InnerTotal
      def self.output_type
        Summary::OutputType.define(:inner_total) do
          label "Total score"
          compute { |_config, run, _so_far| InnerTotal.total(run.run) }
        end
      end

      def self.register(registry = Summary.registry)
        registry.register(output_type)
      end

      def self.total(parent)
        parent.inner_runs.sum { |inner| score_of(inner).to_i }
      end

      def self.score_of(inner)
        Flow::Summaries.new(inner.flow).score_of(inner, inner.walked(inner.recorded).transform_keys(&:to_s))
      end
    end
  end
end
