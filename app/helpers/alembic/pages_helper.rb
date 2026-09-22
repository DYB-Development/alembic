require "ks_blocks/layout_helper"

module Alembic
  module PagesHelper
    def drawn_page(page)
      block_layout(drawn_blocks(page), kind: :pages) do |block|
        drawn_block(block)
      end
    end

    def drawn_block(block)
      component = Page::Drawing.of(block["type"])

      send(component, **Page::Options.for(block)) if component
    end

    private

    def drawn_blocks(page)
      page.blocks.select { |block| Page::Drawing.of(block["type"]) }
    end
  end
end
