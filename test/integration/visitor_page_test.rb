require "test_helper"

module Alembic
  class VisitorPageTest < ActionDispatch::IntegrationTest
    test "a visitor opening a page's address is shown the finished page" do
      get alembic.page_path(welcoming_page.slug)

      assert_includes response.body, "Our team"
    end

    test "a visitor opening a slug no page holds is refused" do
      get alembic.page_path("nothing-here")

      assert_response :not_found
    end

    test "a flow and a page can hold the same slug" do
      welcoming_page
      Flow::Definition.create!(slug: "welcome", title: "Welcome")

      get alembic.page_path("welcome")

      assert_includes response.body, "Our team"
    end

    private

    def welcoming_page
      page = Page.create!(name: "Welcome", slug: "welcome")
      page.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :section }, x: 0, y: 0)
      page.fill_block(page.reload.blocks.first["id"], { "title" => "Our team" })
      page.reload
    end
  end
end
