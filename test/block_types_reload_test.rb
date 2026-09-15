require "test_helper"

class BlockTypesReloadTest < ActiveSupport::TestCase
  test "block types the host app registers are registered again after a code reload" do
    Alembic::Pages.instance_variable_set(:@registry, nil)

    Rails.application.reloader.prepare!

    assert_includes Alembic::Pages.registry.block_types.map(&:key), :heading
  end
end
