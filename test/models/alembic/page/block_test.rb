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
        Page::Drawing.instance_variable_set(:@components, nil)
      end

      test "registering a page block type offers it to a designer" do
        Page.block(:quote, name: "Quote", width: 6, height: 2, drawn_by: :ui_quote)

        assert_includes KsBlocks.registry.block_types(kind: :pages).map(&:key), :quote
      end

      test "keeps the component a block type is drawn with" do
        Page::Drawing.record(:quote, :ui_quote)

        assert_equal :ui_quote, Page::Drawing.of(:quote)
      end

      test "tells which component draws a registered page block type" do
        Page.block(:quote, name: "Quote", width: 6, height: 2, drawn_by: :ui_quote)

        assert_equal :ui_quote, Page::Drawing.of(:quote)
      end

      test "tells there is no component for a page block type registered without one" do
        Page.block(:quote, name: "Quote", width: 6, height: 2)

        assert_nil Page::Drawing.of(:quote)
      end
    end
  end
end
