require "ks_blocks/layout_helper"

module Alembic
  module PagesHelper
    UNDRAWABLE = "This block cannot be drawn until its fields are filled in.".freeze

    def drawn_page(page, being_edited: false, values: {})
      blocks = being_edited ? page.blocks : page.live_version&.blocks.to_a
      drawn = blocks.to_h { |block| [ block["id"], drawn_block(block, values: values) ] }.compact

      block_layout(blocks.select { |block| drawn.key?(block["id"]) }, kind: :pages) do |block|
        drawn.fetch(block["id"])
      end
    end

    def drawn_block(block, values: {})
      component = Page::Drawing.of(block["type"])
      return unless component

      options = Page::Options.for(block, values: values)
      body = Page::Options.body_for(block)
      body.nil? ? send(component, **options) : send(component, **options) { body }
    rescue StandardError => undrawable
      Rails.logger.error("Alembic could not draw the #{block['type']} block: #{undrawable.message}")
      nil
    end

    def shown_block(block)
      drawn_block(block) || undrawn_block(block)
    end

    private

    def undrawn_block(block)
      return UNDRAWABLE if Page::Drawing.of(block["type"])

      KsBlocks.registry.block_types(kind: :pages).find { |type| type.key.to_s == block["type"] }&.name
    end
  end
end
