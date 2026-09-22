module Alembic
  class Page < ApplicationRecord
    module Options
      def self.declare(key, options)
        declared[key.to_sym] = options
      end

      def self.for(block)
        named(filled(block), declared.fetch(block["type"].to_sym, {}))
      end

      def self.declared
        @declared ||= {}
      end

      def self.filled(block)
        block.fetch("content", {}).reject { |_key, value| value == "" }.symbolize_keys
      end

      def self.named(filled, options)
        options.each_with_object(filled) do |(option, spec), built|
          field = spec.fetch(:from, option)
          value = built.delete(field)
          built[option] = value.nil? ? spec[:default] : value
          built.delete(option) if built[option].nil?
        end
      end

      private_class_method :filled, :named
    end
  end
end
