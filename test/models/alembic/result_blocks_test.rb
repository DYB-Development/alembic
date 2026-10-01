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

      assert_equal %i[alembic_score alembic_band alembic_categories alembic_weakest alembic_answers alembic_outcome alembic_outcomes], offered
    end

    test "offers a lead block when the host names a lead address" do
      Alembic.lead_address = ->(slug) { "/labs/#{slug}/interest" }

      ResultBlocks.register

      assert_includes offered, :alembic_lead
    ensure
      Alembic.lead_address = nil
    end

    private

    def offered
      KsBlocks.registry.block_types(kind: :pages).map(&:key)
    end
  end
end
