require "test_helper"

module Alembic
  class ResultBlocksTest < ActiveSupport::TestCase
    setup do
      @registry = KsBlocks.registry
      @declarations = declarations
      KsBlocks.instance_variable_set(:@registry, KsBlocks::Registry.new)
    end

    teardown do
      KsBlocks.instance_variable_set(:@registry, @registry)
      restore(@declarations)
    end

    test "offers the page builder a block for each kind of result" do
      ResultBlocks.register

      assert_equal %i[alembic_score alembic_band alembic_categories alembic_weakest alembic_answers], offered
    end

    private

    def offered
      KsBlocks.registry.block_types(kind: :pages).map(&:key)
    end
  end
end
