import React from "react"
import GridLayout, { useContainerWidth } from "react-grid-layout"
import Button from "../../keystone_ui/react/Button"
import Panel from "../../keystone_ui/react/Panel"
import usePage from "./usePage"
import { addBlock } from "./blocks"

const COLUMNS = 12
const ROW_HEIGHT = 60

const named = (block_types, key) => block_types.find((blockType) => blockType.key === key)?.name

export default function PageBuilder({ base, token, ...initial }) {
  const { page, send } = usePage(base, token, initial)
  const { name, pages, block_types = [], blocks = [] } = page
  const { width, containerRef } = useContainerWidth()
  const layout = blocks.map(({ id, x, y, w, h }) => ({ i: id, x, y, w, h }))

  return (
    <div>
      <h1>{name}</h1>
      <Button href={pages} data-all-pages>All pages</Button>
      {block_types.length === 0
        ? <p>There are no blocks to add.</p>
        : <ul>
            {block_types.map((blockType) => (
              <li key={blockType.key} data-block-type={blockType.key}>
                {blockType.name}
                <Button variant="secondary" size="sm" type="button" onClick={() => addBlock(send, blockType.key)}>Add</Button>
              </li>
            ))}
          </ul>}
      <Panel data-page-panel>
        {blocks.length === 0 && <p>This page has no blocks yet.</p>}
        <div ref={containerRef}>
          <GridLayout width={width} layout={layout} gridConfig={{ cols: COLUMNS, rowHeight: ROW_HEIGHT }}>
            {blocks.map((block) => <div key={block.id} data-block={block.id}>{named(block_types, block.type)}</div>)}
          </GridLayout>
        </div>
      </Panel>
    </div>
  )
}
