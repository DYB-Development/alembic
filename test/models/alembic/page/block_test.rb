require "test_helper"

module Alembic
  class Page
    class BlockTest < ActiveSupport::TestCase
      setup do
        @registry = KsBlocks.registry
        KsBlocks.instance_variable_set(:@registry, KsBlocks::Registry.new)
      end

      teardown do
        KsBlocks.instance_variable_set(:@registry, @registry)
      end

      test "registering a page block type offers it to a designer" do
        Page.block(:quote, name: "Quote", width: 6, height: 2, drawn_by: :ui_quote)

        assert_includes KsBlocks.registry.block_types(kind: :pages).map(&:key), :quote
      end
    end
  end
end
