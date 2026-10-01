require "test_helper"

module Alembic
  class Page
    class ContentBlocksTest < ActiveSupport::TestCase
      setup do
        @registry = KsBlocks.registry
        @declarations = declarations
        KsBlocks.instance_variable_set(:@registry, KsBlocks::Registry.new)
      end

      teardown do
        KsBlocks.instance_variable_set(:@registry, @registry)
        restore(@declarations)
      end

      test "offers the page builder a hero, facts, a table, code and a start button" do
        ContentBlocks.register

        assert_equal %i[alembic_hero alembic_facts alembic_table alembic_code alembic_start],
          KsBlocks.registry.block_types(kind: :pages).map(&:key)
      end
    end
  end
end
