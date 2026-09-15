require "test_helper"

module Alembic
  class PageTest < ActiveSupport::TestCase
    test "is invalid without a name" do
      assert_not Page.new(name: "").valid?
    end

    test "starts with no blocks" do
      assert_equal [], Page.create!(name: "Welcome").blocks
    end

    test "adding a block stores its type and position at the type's starting size" do
      page = Page.create!(name: "Welcome")

      page.add_block(Pages::BlockType.new(key: :text, name: "Text", width: 6, height: 2), x: 3, y: 1)

      assert_equal({ "type" => "text", "x" => 3, "y" => 1, "w" => 6, "h" => 2 }, page.reload.blocks.first.except("id"))
    end

    test "gives each added block its own id" do
      page = Page.create!(name: "Welcome")
      text = Pages::BlockType.new(key: :text, name: "Text", width: 6, height: 2)

      page.add_block(text, x: 0, y: 0)
      page.add_block(text, x: 6, y: 0)

      assert_equal 2, page.reload.blocks.map { |block| block["id"] }.compact.uniq.size
    end

    test "adding a block with no position places it beside the blocks already on the row" do
      page = Page.create!(name: "Welcome")
      text = Pages::BlockType.new(key: :text, name: "Text", width: 6, height: 2)
      page.add_block(text, x: 0, y: 0)

      page.add_block(text)

      assert_equal [ 6, 0 ], page.reload.blocks.last.values_at("x", "y")
    end
  end
end
