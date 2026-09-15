require "test_helper"

module Alembic
  class PagesTest < ActiveSupport::TestCase
    test "declaring a block type puts it in the default registry" do
      Pages.block(:registry_probe, name: "Probe", width: 4, height: 2)

      assert_includes Pages.registry.block_types, Pages::BlockType.new(key: :registry_probe, name: "Probe", width: 4, height: 2)
    end
  end
end
