require "test_helper"

module Alembic
  class PageTest < ActiveSupport::TestCase
    test "is invalid without a name" do
      assert_not Page.new(name: "").valid?
    end

    test "refuses a slug another page already holds" do
      Page.create!(name: "Welcome", slug: "welcome")

      assert_not Page.new(name: "Second", slug: "welcome").valid?
    end

    test "starts with no blocks" do
      assert_equal [], Page.create!(name: "Welcome").blocks
    end

    test "adding a block stores its type and position at the type's starting size" do
      page = Page.create!(name: "Welcome")

      page.add_block(KsBlocks::BlockType.new(key: :text, name: "Text", width: 6, height: 2), x: 3, y: 1)

      assert_equal({ "type" => "text", "x" => 3, "y" => 1, "w" => 6, "h" => 2 }, page.reload.blocks.first.except("id"))
    end

    test "gives each added block its own id" do
      page = Page.create!(name: "Welcome")
      text = KsBlocks::BlockType.new(key: :text, name: "Text", width: 6, height: 2)

      page.add_block(text, x: 0, y: 0)
      page.add_block(text, x: 6, y: 0)

      assert_equal 2, page.reload.blocks.map { |block| block["id"] }.compact.uniq.size
    end

    test "adding a block with no position places it beside the blocks already on the row" do
      page = Page.create!(name: "Welcome")
      text = KsBlocks::BlockType.new(key: :text, name: "Text", width: 6, height: 2)
      page.add_block(text, x: 0, y: 0)

      page.add_block(text)

      assert_equal [ 6, 0 ], page.reload.blocks.last.values_at("x", "y")
    end

    test "adding a block with no position places it below when the row has no room" do
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks::BlockType.new(key: :heading, name: "Heading", width: 12, height: 1), x: 0, y: 0)

      page.add_block(KsBlocks::BlockType.new(key: :text, name: "Text", width: 6, height: 2))

      assert_equal [ 0, 1 ], page.reload.blocks.last.values_at("x", "y")
    end

    test "placing blocks moves each named block to its new position" do
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks::BlockType.new(key: :text, name: "Text", width: 6, height: 2), x: 0, y: 0)
      id = page.blocks.first["id"]

      page.place_blocks([ { "id" => id, "x" => 6, "y" => 3 } ])

      assert_equal [ 6, 3 ], page.reload.blocks.first.values_at("x", "y")
    end

    test "placing blocks gives each named block its new size" do
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks::BlockType.new(key: :text, name: "Text", width: 6, height: 2), x: 0, y: 0)

      page.place_blocks([ { "id" => page.blocks.first["id"], "x" => 0, "y" => 0, "w" => 8, "h" => 3 } ])

      assert_equal [ 8, 3 ], page.reload.blocks.first.values_at("w", "h")
    end

    test "removing a block takes only that block off the page" do
      page = Page.create!(name: "Welcome")
      text = KsBlocks::BlockType.new(key: :text, name: "Text", width: 6, height: 2)
      page.add_block(text, x: 0, y: 0)
      page.add_block(text, x: 6, y: 0)
      kept, removed = page.blocks.map { |block| block["id"] }

      page.remove_block(removed)

      assert_equal [ kept ], page.reload.blocks.map { |block| block["id"] }
    end
  end
end
