require "test_helper"

module Alembic
  class BlockDrawingTest < ActionDispatch::IntegrationTest
    setup do
      @registry = KsBlocks.registry
      KsBlocks.instance_variable_set(:@registry, KsBlocks::Registry.new)
      Page.block(:badge, name: "Badge", width: 3, height: 1, drawn_by: :ui_badge, fields: [ { key: :label, label: "Label" } ])
    end

    teardown do
      KsBlocks.instance_variable_set(:@registry, @registry)
      Page::Drawing.instance_variable_set(:@components, nil)
    end

    test "a block is drawn with the component its type names" do
      page = badged_page("New")

      get alembic.manage_page_layout_path(page)

      assert_includes drawn(page), "ks-badge"
    end

    test "a block whose type names no component still shows the type's name" do
      KsBlocks.block(:spacer, name: "Spacer", width: 3, height: 1, kind: :pages)
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :spacer }, x: 0, y: 0)

      get alembic.manage_page_layout_path(page)

      assert_includes drawn(page), "Spacer"
    end

    test "a field left empty is passed to the component as no value" do
      page = badged_page("New")
      page.fill_block(page.blocks.first["id"], { "label" => "New", "variant" => "" })

      get alembic.manage_page_layout_path(page)

      assert_includes drawn(page), "ks-badge-neutral"
    end

    private

    def badged_page(label)
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks.registry.block_types(kind: :pages).first, x: 0, y: 0)
      page.fill_block(page.blocks.first["id"], { "label" => label })
      page
    end

    def drawn(page)
      JSON.parse(response.body).fetch("contents").fetch(page.reload.blocks.first["id"])
    end
  end
end
