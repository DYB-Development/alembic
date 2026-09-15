module Alembic
  module Pages
    class << self
      def block(key, name:, width:, height:)
        registry.register(BlockType.new(key: key, name: name, width: width, height: height))
      end

      def registry
        @registry ||= Registry.new
      end
    end
  end
end
