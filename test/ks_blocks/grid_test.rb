require "test_helper"
require "ks_blocks/grid"

module KsBlocks
  class GridTest < ActiveSupport::TestCase
    TEXT = BlockType.new(key: :text, name: "Text", width: 6, height: 2)

    test "adding a block puts it at the given position at its type's starting size" do
      blocks = Grid.add([], TEXT, x: 3, y: 1)

      assert_equal({ "type" => "text", "x" => 3, "y" => 1, "w" => 6, "h" => 2 }, blocks.first.except("id"))
    end

    test "gives each added block its own id" do
      blocks = Grid.add(Grid.add([], TEXT, x: 0, y: 0), TEXT, x: 6, y: 0)

      assert_equal 2, blocks.map { |block| block["id"] }.compact.uniq.size
    end

    test "adding a block with no position places it beside the blocks already on the row" do
      blocks = Grid.add(Grid.add([], TEXT, x: 0, y: 0), TEXT)

      assert_equal [ 6, 0 ], blocks.last.values_at("x", "y")
    end

    test "adding a block with no position places it below when the row has no room" do
      heading = BlockType.new(key: :heading, name: "Heading", width: 12, height: 1)

      blocks = Grid.add(Grid.add([], heading, x: 0, y: 0), TEXT)

      assert_equal [ 0, 1 ], blocks.last.values_at("x", "y")
    end

    test "placing blocks gives each named block its new position and size" do
      blocks = Grid.add([], TEXT, x: 0, y: 0)

      placed = Grid.place(blocks, [ { "id" => blocks.first["id"], "x" => 6, "y" => 3, "w" => 4, "h" => 1 } ])

      assert_equal [ 6, 3, 4, 1 ], placed.first.values_at("x", "y", "w", "h")
    end
  end
end
