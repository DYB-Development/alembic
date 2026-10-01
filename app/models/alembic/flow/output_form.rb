module Alembic
  module Flow
    module OutputForm
      def self.edited(current, submitted)
        submitted.sort_by { |index, _| index.to_i }.map do |index, output|
          current.fetch(index.to_i, {}).merge(output).merge(listed_bands(output)).merge(counted(output))
        end
      end

      def self.counted(output)
        output.key?("count") ? { "count" => output["count"].presence&.to_i } : {}
      end

      def self.listed_bands(output)
        return {} unless output["bands"].is_a?(Hash)

        named = output["bands"].sort_by { |position, _| position.to_i }.map(&:last).select { |band| band["name"].present? }
        { "bands" => named.map { |band| band.merge("ceiling" => band["ceiling"].presence&.to_i) } }
      end

      private_class_method :counted, :listed_bands
    end
  end
end
