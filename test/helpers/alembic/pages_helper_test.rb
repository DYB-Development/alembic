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

    test "leaves out a block whose type names no component" do
      KsBlocks.block(:spacer, name: "Spacer", width: 3, height: 1, kind: :pages)
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :spacer }, x: 0, y: 0)

      assert_no_match(/data-block=/, drawn_page(page.reload))
    end

    test "leaves a block it cannot draw off the finished page" do
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks.registry.block_types(kind: :pages).first, x: 0, y: 0)

      assert_no_match(/data-block=/, drawn_page(page.reload))
    end

    test "writes why a block could not be drawn to the log" do
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks.registry.block_types(kind: :pages).first, x: 0, y: 0)

      assert_match "missing keyword: :label", logged { drawn_page(page.reload) }
    end

    test "draws the field a type names as its component's body inside the component" do
        Page.block(:panel, name: "Panel", width: 6, height: 3, drawn_by: :ui_panel,
          fields: [ { key: :text, label: "Text" } ], body: :text)
        page = Page.create!(name: "Welcome")
        page.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :panel }, x: 0, y: 0)
        page.fill_block(page.reload.blocks.first["id"], { "text" => "Ready when you are" })

        assert_includes drawn_page(page.reload), "Ready when you are"
      end

    test "escapes the text a designer types into a body field" do
      Page.block(:panel, name: "Panel", width: 6, height: 3, drawn_by: :ui_panel,
        fields: [ { key: :text, label: "Text" } ], body: :text)
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == :panel }, x: 0, y: 0)
      page.fill_block(page.reload.blocks.first["id"], { "text" => "<script>alert(1)</script>" })

      assert_includes drawn_page(page.reload), "&lt;script&gt;"
    end

    private

    def logged
      written = StringIO.new
      kept, Rails.logger = Rails.logger, Logger.new(written)
      yield
      written.string
    ensure
      Rails.logger = kept
    end


    def badged_page(label, x: 0, y: 0)
      page = Page.create!(name: "Welcome")
      page.add_block(KsBlocks.registry.block_types(kind: :pages).first, x: x, y: y)
      page.fill_block(page.blocks.first["id"], { "label" => label })
      page.reload
    end
  end
end
