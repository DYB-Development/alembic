require "test_helper"
require "ks_blocks"

class KsBlocksTest < ActiveSupport::TestCase
  test "declaring a block type puts it in the default registry" do
    KsBlocks.block(:ks_blocks_probe, name: "Probe", width: 4, height: 2)

    assert_includes KsBlocks.registry.block_types, KsBlocks::BlockType.new(key: :ks_blocks_probe, name: "Probe", width: 4, height: 2)
  end

  test "layout data carries the blocks it is given" do
    blocks = [ { "id" => "b1", "type" => "text", "x" => 0, "y" => 0, "w" => 6, "h" => 2 } ]

    assert_equal blocks, KsBlocks.layout_data(blocks)[:blocks]
  end

  test "layout data lists each registered block type's key, name and starting size" do
    KsBlocks.block(:layout_data_probe, name: "Layout probe", width: 3, height: 1)

    assert_includes KsBlocks.layout_data([])[:block_types], { key: :layout_data_probe, name: "Layout probe", width: 3, height: 1 }
  end

  test "layout data's version changes when the blocks change" do
    before = [ { "id" => "b1", "type" => "text", "x" => 0, "y" => 0, "w" => 6, "h" => 2 } ]
    after = [ { "id" => "b1", "type" => "text", "x" => 6, "y" => 0, "w" => 6, "h" => 2 } ]

    assert_not_equal KsBlocks.layout_data(before)[:version], KsBlocks.layout_data(after)[:version]
  end

  test "declaring a block type for a kind of layout offers it only for that kind" do
    KsBlocks.block(:dashboard_probe, name: "Dashboard probe", width: 3, height: 1, kind: :dashboards)

    assert_equal [], KsBlocks.registry.block_types(kind: :pages).select { |block_type| block_type.key == :dashboard_probe }
  end

  test "layout data lists only the block types of the kind of layout it is for" do
    KsBlocks.block(:layout_data_dashboard_probe, name: "Dashboard probe", width: 3, height: 1, kind: :dashboards)

    assert_equal [], KsBlocks.layout_data([], kind: :pages)[:block_types].select { |block_type| block_type[:key] == :layout_data_dashboard_probe }
  end
end
