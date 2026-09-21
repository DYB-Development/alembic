module Alembic
  class Page < ApplicationRecord
    module Options
      def self.for(block)
        block.fetch("content", {}).reject { |_key, value| value == "" }.symbolize_keys
      end
    end
  end
end
