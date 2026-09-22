require "ks_blocks/layout_helper"

module Alembic
  module PagesHelper
    UNDRAWABLE = "This block cannot be drawn until its fields are filled in.".freeze

    def drawn_page(page)
      drawn = page.blocks.to_h { |block| [ block["id"], drawn_block(block) ] }.compact

      block_layout(page.blocks.select { |block| drawn.key?(block["id"]) }, kind: :pages) do |block|
        drawn.fetch(block["id"])
      end
    end

    def drawn_block(block)
      component = Page::Drawing.of(block["type"])
      return unless component

      body = Page::Options.body_for(block)
      body.nil? ? send(component, **Page::Options.for(block)) : send(component, **Page::Options.for(block)) { body }
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
