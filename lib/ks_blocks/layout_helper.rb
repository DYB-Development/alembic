require "ks_blocks/grid"

module KsBlocks
  module LayoutHelper
    def block_layout(blocks, columns: Grid::COLUMNS, gap: Grid::GAP, &block)
      tag.div(style: "display: grid; grid-template-columns: repeat(#{columns}, minmax(0, 1fr)); gap: #{gap}px") do
        safe_join(blocks.map { |placed| block_layout_block(placed, &block) })
      end
    end

    private

    def block_layout_block(placed, &block)
      tag.div(capture(placed, &block), style: "grid-column: #{placed['x'] + 1} / span #{placed['w']}; grid-row: #{placed['y'] + 1} / span #{placed['h']}")
    end
  end
end
