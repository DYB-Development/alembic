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

    test "the page builder previews a page a flow finishes on with that flow's sample results" do
      page = scored_page
      Flow::Summaries.new(scored_flow).finish_on(page)

      get alembic.manage_page_path(page)

      assert_includes response.body, "50%"
    end

    private

    def scored_flow
      EasyFlow::Definition.create!(host: "alembic", slug: "scored").tap do |flow|
        flow.record_definition(flowing("slug" => "scored", "entry" => "a",
          "nodes" => [ { "id" => "a", "type" => "question", "text" => "A?", "options" => [ { "value" => "y", "weight" => 2 }, { "value" => "n", "weight" => 0 } ] },
                       { "id" => "b", "type" => "question", "text" => "B?", "options" => [ { "value" => "y", "weight" => 2 }, { "value" => "n", "weight" => 0 } ] } ],
          "edges" => [ { "from" => "a", "to" => "b" } ]))
        flow.publish
        Flow::Summaries.new(flow).record("outputs" => [ { "id" => "share", "type" => "percentage" } ])
      end
    end

    def scored_page
      Page.create!(name: "Result").tap do |page|
        page.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :alembic_score }, x: 0, y: 0)
        page.fill_block(page.blocks.first["id"], { "output" => "share" })
      end
    end
  end
end
