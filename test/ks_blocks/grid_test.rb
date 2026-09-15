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
  end
end
