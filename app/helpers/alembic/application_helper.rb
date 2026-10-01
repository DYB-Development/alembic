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

    def alembic_entry_texts(entry)
      { "facts_text" => Array(entry["facts"]).map { |pair| pair.join(" | ") }.join("\n"),
        "sections_text" => Array(entry["sections"]).map { |section| section.values_at("heading", "text", "note").compact.join(" | ") }.join("\n"),
        "steps_text" => Array(entry["steps"]).map { |step| "#{step['title']}\n#{step['code']}" }.join("\n---\n") }
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
