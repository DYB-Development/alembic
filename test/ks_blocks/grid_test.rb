require "test_helper"
require "ks_blocks/grid"

module KsBlocks
  class GridTest < ActiveSupport::TestCase
    TEXT = BlockType.new(key: :text, name: "Text", width: 6, height: 2)

    test "adding a block puts it at the given position at its type's starting size" do
      blocks = Grid.add([], TEXT, x: 3, y: 1)

      assert_equal({ "type" => "text", "x" => 3, "y" => 1, "w" => 6, "h" => 2 }, blocks.first.except("id"))
    end
  end
end
