module Alembic
  module Flow
    module OutputForm
      def self.edited(current, submitted)
        submitted.sort_by { |index, _| index.to_i }.map do |index, output|
          current.fetch(index.to_i, {}).merge(output.except("rules_text")).merge(listed_bands(output)).merge(counted(output))
            .merge(ruled(output))
        end
      end

      def self.ruled(output)
        return {} unless output.key?("rules_text")

        rules = output["rules_text"].to_s.lines.map(&:strip).compact_blank.map do |line|
          entry, conditions = line.split(":", 2)
          { "entry" => entry.strip, "when" => conditions.to_s.split(",").map(&:strip).compact_blank.map { |condition| condition_from(condition) } }
        end
        { "rules" => rules }
      end

      def self.condition_from(text)
        step, answer = text.split(/\s+is not\s+/, 2)
        return { "step" => step, "is_not" => answer } if answer

        step, answer = text.split(/\s+is\s+/, 2)
        { "step" => step, "is" => answer }
      end

      def self.counted(output)
        output.key?("count") ? { "count" => output["count"].presence&.to_i } : {}
      end

      def self.listed_bands(output)
        return {} unless output["bands"].is_a?(Hash)

        named = output["bands"].sort_by { |position, _| position.to_i }.map(&:last).select { |band| band["name"].present? }
        { "bands" => named.map { |band| band.merge("ceiling" => band["ceiling"].presence&.to_i) } }
      end

      private_class_method :counted, :listed_bands, :ruled, :condition_from
    end
  end
end
