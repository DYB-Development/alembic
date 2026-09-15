import React, { useRef } from "react"
import GridLayout, { useContainerWidth } from "react-grid-layout"
import Button from "../../keystone_ui/react/Button"
import Panel from "../../keystone_ui/react/Panel"
import Page from "../../keystone_ui/react/Page"
import PageHeader from "../../keystone_ui/react/PageHeader"
import Section from "../../keystone_ui/react/Section"
import usePage from "./usePage"
import { addBlock, dropBlock } from "./blocks"

const COLUMNS = 12
const ROW_HEIGHT = 60

const named = (block_types, key) => block_types.find((blockType) => blockType.key === key)?.name

export default function PageBuilder({ base, token, ...initial }) {
  const { page, send } = usePage(base, token, initial)
  const { name, pages, block_types = [], blocks = [] } = page
  const { width, containerRef } = useContainerWidth()
  const layout = blocks.map(({ id, x, y, w, h }) => ({ i: id, x, y, w, h }))
  const dragged = useRef(null)

  const startDragging = (blockType) => (event) => {
    dragged.current = blockType
    event.dataTransfer.setData("text/plain", blockType.key)
  }

  const dropConfig = {
    enabled: true,
    onDragOver: () => dragged.current ? { w: dragged.current.width, h: dragged.current.height } : false
  }

  const dropped = (_layout, item) => {
    if (dragged.current) dropBlock(send, dragged.current.key, item)
    dragged.current = null
  }

  return (
    <Page>
      <div className="sm:hidden mb-4 flex items-center justify-between gap-3">
        <h1 className="ks-page-header-title">{name}</h1>
        <Button href={pages} size="sm">All pages</Button>
      </div>
      <PageHeader title={name} actions={<Button href={pages} data-all-pages>All pages</Button>} />
      <div className="lg:grid lg:grid-cols-[16rem_minmax(0,1fr)] lg:gap-6">
        <Section title="Blocks" spacing="sm">
          {block_types.length === 0
            ? <p>There are no blocks to add.</p>
            : <ul>
                {block_types.map((blockType) => (
                  <li key={blockType.key} data-block-type={blockType.key} draggable="true" onDragStart={startDragging(blockType)}>
                    {blockType.name}
                    <Button variant="secondary" size="sm" type="button" onClick={() => addBlock(send, blockType.key)}>Add</Button>
                  </li>
                ))}
              </ul>}
        </Section>
        <Panel data-page-panel>
          {blocks.length === 0 && <p>This page has no blocks yet.</p>}
          <div ref={containerRef} data-page-grid style={{ overflow: "hidden" }}>
            <GridLayout width={width} layout={layout} gridConfig={{ cols: COLUMNS, rowHeight: ROW_HEIGHT }} dropConfig={dropConfig} onDrop={dropped}>
              {blocks.map((block) => <div key={block.id} data-block={block.id} className="ks-panel">{named(block_types, block.type)}</div>)}
            </GridLayout>
          </div>
        </Panel>
      </div>
    </Page>
  )
}
