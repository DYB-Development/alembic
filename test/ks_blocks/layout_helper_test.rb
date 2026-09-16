require "test_helper"
require "ks_blocks/layout_helper"

module KsBlocks
  class LayoutHelperTest < ActionView::TestCase
    include KsBlocks::LayoutHelper

    test "a block is placed at the column and row it was saved at" do
      blocks = [ { "id" => "b1", "type" => "text", "x" => 3, "y" => 2, "w" => 4, "h" => 2 } ]

      rendered = block_layout(blocks, columns: 12) { |block| block["id"] }

      assert_match(/grid-column: ?4 ?\/ ?span 4; ?grid-row: ?3 ?\/ ?span 2/, rendered)
    end
  end
end
