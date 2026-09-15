module Alembic
  module Pages
    class Registry
      def initialize
        @block_types = {}
      end

      def register(block_type)
        @block_types[block_type.key.to_sym] = block_type
      end

      def block_types
        @block_types.values
      end
    end
  end
end
