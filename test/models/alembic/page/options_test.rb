require "test_helper"

module Alembic
  class Page
    class OptionsTest < ActiveSupport::TestCase
      setup do
        @registry = KsBlocks.registry
        KsBlocks.instance_variable_set(:@registry, KsBlocks::Registry.new)
      end

      teardown do
        KsBlocks.instance_variable_set(:@registry, @registry)
        Page::Drawing.instance_variable_set(:@components, nil)
        Page::Options.instance_variable_set(:@declared, nil)
      end

      test "fills the option a field is mapped onto" do
        Page.block(:hero, name: "Hero", width: 12, height: 3, drawn_by: :ui_hero,
          fields: [ { key: :headline, label: "Headline" } ], options: { title: { from: :headline } })

        assert_equal({ title: "Welcome" }, Page::Options.for(block_of("hero", "headline" => "Welcome")))
      end

      test "gives an option its default when the field is empty" do
        Page.block(:hero, name: "Hero", width: 12, height: 3, drawn_by: :ui_hero,
          fields: [ { key: :title, label: "Title" } ], options: { title: { default: "Your headline" } })

        assert_equal({ title: "Your headline" }, Page::Options.for(block_of("hero", "title" => "")))
      end

      test "draws every block of a type with an option's fixed value" do
        Page.block(:hero, name: "Hero", width: 12, height: 3, drawn_by: :ui_hero,
          fields: [ { key: :title, label: "Title" } ], options: { layout: "split" })

        assert_equal "split", Page::Options.for(block_of("hero", "title" => "Welcome"))[:layout]
      end

      test "fills the option of a field's own name when nothing maps it" do
        Page.block(:badge, name: "Badge", width: 3, height: 1, drawn_by: :ui_badge,
          fields: [ { key: :label, label: "Label" } ])

        assert_equal({ label: "New" }, Page::Options.for(block_of("badge", "label" => "New")))
      end

      private

      def block_of(type, content)
        { "id" => "b1", "type" => type, "content" => content }
      end
    end
  end
end
