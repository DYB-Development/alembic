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

    test "removing a block takes only that block off the grid" do
      blocks = Grid.add(Grid.add([], TEXT, x: 0, y: 0), TEXT, x: 6, y: 0)
      kept, removed = blocks.map { |block| block["id"] }

      assert_equal [ kept ], Grid.remove(blocks, removed).map { |block| block["id"] }
    end

    test "placing blocks so they overlap is refused with a message naming both" do
      KsBlocks.block(:text, name: "Text", width: 6, height: 2)
      KsBlocks.block(:heading, name: "Heading", width: 12, height: 1)
      blocks = Grid.add(Grid.add([], TEXT, x: 0, y: 0), BlockType.new(key: :heading, name: "Heading", width: 12, height: 1), x: 0, y: 2)
      heading = blocks.last["id"]

      error = assert_raises(InvalidLayout) { Grid.place(blocks, [ { "id" => heading, "x" => 0, "y" => 1, "w" => 12, "h" => 1 } ]) }

      assert_equal "Heading overlaps Text", error.message
    end

    test "placing a block past the grid's last column is refused with a message naming it" do
      KsBlocks.block(:text, name: "Text", width: 6, height: 2)
      blocks = Grid.add([], TEXT, x: 0, y: 0)

      error = assert_raises(InvalidLayout) { Grid.place(blocks, [ { "id" => blocks.first["id"], "x" => 8, "y" => 0, "w" => 6, "h" => 2 } ]) }

      assert_equal "Text runs past the grid's last column", error.message
    end

    test "placing a block narrower or shorter than one cell is refused with a message naming it" do
      KsBlocks.block(:text, name: "Text", width: 6, height: 2)
      blocks = Grid.add([], TEXT, x: 0, y: 0)

      error = assert_raises(InvalidLayout) { Grid.place(blocks, [ { "id" => blocks.first["id"], "x" => 0, "y" => 0, "w" => 6, "h" => 0 } ]) }

      assert_equal "Text must be at least one column wide and one row tall", error.message
    end
  end
end
