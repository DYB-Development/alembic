module Alembic
  module Outputs
    module Outcome
      def self.output_type
        Summary::OutputType.define(:outcome) do
          label "Outcome"
          compute { |config, run, _so_far| Outcome.placed(config, run.state) }
        end
      end

      def self.register(registry = Summary.registry)
        registry.register(output_type)
      end

      def self.placed(config, state)
        entries = Array(config["entries"])
        rule = Array(config["rules"]).find { |candidate| holds?(candidate, state) }

        { "chosen" => entries.find { |entry| entry["key"] == rule&.dig("entry") }, "entries" => entries }
      end

      def self.holds?(rule, state)
        Array(rule["when"]).all? { |condition| state[condition["step"]].to_s == condition["is"].to_s }
      end
    end
  end
end
