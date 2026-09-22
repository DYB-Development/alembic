require "ks_blocks/layout_helper"

module Alembic
  module PagesHelper
    def drawn_page(page)
      block_layout(page.blocks, kind: :pages) do |block|
        send(Page::Drawing.of(block["type"]), **Page::Options.for(block))
      end
    end
  end
end
