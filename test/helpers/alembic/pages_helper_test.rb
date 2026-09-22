require "test_helper"

module Alembic
  class PagesHelperTest < ActionView::TestCase
    tests Alembic::PagesHelper

    include KeystoneUiHelper
    include KsBlocks::LayoutHelper

    setup do
      @registry = KsBlocks.registry
      KsBlocks.instance_variable_set(:@registry, KsBlocks::Registry.new)
      Page.block(:badge, name: "Badge", width: 3, height: 1, drawn_by: :ui_badge, fields: [ { key: :label, label: "Label" } ])
    end

    teardown do
      KsBlocks.instance_variable_set(:@registry, @registry)
      Page::Drawing.instance_variable_set(:@components, nil)
    end

    test "draws a block with the component its type names" do
      assert_includes drawn_page(badged_page("New")), "ks-badge"
    end

    test "draws a block's content as the component's options" do
      assert_includes drawn_page(badged_page("New")), "New"
    end

    test "places a block where the designer put it" do
      page = badged_page("New", x: 3, y: 2)

      assert_includes drawn_page(page), "--ks-block-x: 3; --ks-block-y: 2"
    end

    private

    def badged_page(label, x: 0, y: 0)
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks.registry.block_types(kind: :pages).first, x: x, y: y)
      page.fill_block(page.blocks.first["id"], { "label" => label })
      page.reload
    end
  end
end
