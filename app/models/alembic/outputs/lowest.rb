module Alembic
  module Outputs
    module Lowest
      def self.output_type
        Summary::OutputType.define(:lowest) do
          label "Weakest"
          compute { |config, _run, so_far| Lowest.of(so_far[config["of"]], config["count"], config["copy"]) }
        end
      end

      def self.register(registry = Summary.registry)
        registry.register(output_type)
      end

      def self.of(shares, count, copy = nil)
        weakest = shares.to_h.sort_by { |_name, share| share }.first(count.presence&.to_i || 1).map(&:first)

        weakest.map { |name| { "name" => name, **copy.to_h.fetch(name, {}).slice("miss", "cost") } }
      end
    end
  end
end
