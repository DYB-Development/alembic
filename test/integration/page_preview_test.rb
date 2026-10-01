require "test_helper"

module Alembic
  class PagePreviewTest < ActionDispatch::IntegrationTest
    setup { @kept_provider = Page::Preview.provider }
    teardown { Page::Preview.provider = @kept_provider }

    test "the page builder draws each block with the preview values the provider gives" do
      Page::Preview.provider = ->(_page, _choice) { { "share" => 64 } }

      get alembic.manage_page_path(scored_page)

      assert_includes response.body, "64%"
    end

    private

    def scored_page
      Page.create!(name: "Result").tap do |page|
        page.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :alembic_score }, x: 0, y: 0)
        page.fill_block(page.blocks.first["id"], { "output" => "share" })
      end
    end
  end
end
