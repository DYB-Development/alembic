require "ks_blocks/layout_helper"

module Alembic
  module PagesHelper
    def drawn_page(page)
      block_layout(drawn_blocks(page), kind: :pages) do |block|
        send(Page::Drawing.of(block["type"]), **Page::Options.for(block))
      end
    end

    private

    def drawn_blocks(page)
      page.blocks.select { |block| Page::Drawing.of(block["type"]) }
    end
  end
end
