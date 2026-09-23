require "test_helper"

module Alembic
  class Page
    class VersionTest < ActiveSupport::TestCase
      test "publishing records the page's blocks as the first version" do
        page = Page.create!(name: "Welcome")
        page.add_block(KsBlocks::BlockType.new(key: :text, name: "Text", width: 6, height: 2), x: 0, y: 0)

        published = page.publish

        assert_equal [ 1, page.reload.blocks ], [ published.number, published.blocks ]
      end

      test "the version just published is the live one" do
        page = Page.create!(name: "Welcome")

        published = page.publish

        assert_equal published, page.reload.live_version
      end

      test "publishing again supersedes the version that was live" do
        page = Page.create!(name: "Welcome")
        first = page.publish

        page.publish

        assert_equal "superseded", first.reload.status
      end
    end
  end
end
