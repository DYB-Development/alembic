module Alembic
  class Page < ApplicationRecord
    module Drawing
      def self.record(key, component)
        components[key.to_sym] = component
      end

      def self.of(key)
        components[key.to_sym]
      end

      def self.components
        @components ||= {}
      end
    end
  end
end
