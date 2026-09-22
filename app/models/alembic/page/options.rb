module Alembic
  class Page < ApplicationRecord
    module Options
      def self.declare(key, options, body: nil)
        declared[key.to_sym] = options
        bodies[key.to_sym] = body
      end

      def self.for(block)
        named(filled(block).except(bodies[block["type"].to_sym]), declared.fetch(block["type"].to_sym, {}))
      end

      def self.body_for(block)
        field = bodies[block["type"].to_sym]

        filled(block)[field] if field
      end

      def self.bodies
        @bodies ||= {}
      end

      def self.declared
        @declared ||= {}
      end

      def self.filled(block)
        block.fetch("content", {}).reject { |_key, value| value == "" }.symbolize_keys
      end

      def self.named(filled, options)
        options.each_with_object(filled) do |(option, spec), built|
          spec.is_a?(Hash) ? fill(built, option, spec) : built[option] = spec
        end
      end

      def self.fill(built, option, spec)
        value = built.delete(spec.fetch(:from, option))
        built[option] = value.nil? ? spec[:default] : value
        built.delete(option) if built[option].nil?
      end

      private_class_method :filled, :named, :fill
    end
  end
end
