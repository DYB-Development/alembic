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

    private

    def badged_page(label)
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks.registry.block_types(kind: :pages).first, x: 0, y: 0)
      page.fill_block(page.blocks.first["id"], { "label" => label })
      page.reload
    end
  end
end
