module Alembic
  module ApplicationHelper
    def alembic_rules_text(rules)
      Array(rules).map do |rule|
        conditions = Array(rule["when"]).map do |condition|
          condition.key?("is_not") ? "#{condition['step']} is not #{condition['is_not']}" : "#{condition['step']} is #{condition['is']}"
        end
        "#{rule['entry']}: #{conditions.join(', ')}".strip
      end.join("\n")
    end

    def alembic_output_lines(value)
      case value
      when Hash then value.key?("name") ? [ value["name"] ] : value.map { |name, share| "#{name}: #{share}" }
      when Array then value.map { |item| item.is_a?(Hash) ? item["name"] : item }
      else [ value ]
      end
    end
  end
end
