import React from "react"
import Button from "keystone_ui-react/src/Button.jsx"
import Page from "keystone_ui-react/src/Page.jsx"
import PageHeader from "keystone_ui-react/src/PageHeader.jsx"
import BlockGrid from "../../ks_blocks/BlockGrid"

export default function PageBuilder({ base, token, name, pages, block_types, blocks, version }) {
  return (
    <Page>
      <div className="sm:hidden mb-4 flex items-center justify-between gap-3">
        <h1 className="ks-page-header-title">{name}</h1>
        <Button href={pages} size="sm">All pages</Button>
      </div>
      <PageHeader title={name} actions={<Button href={pages} data-all-pages>All pages</Button>} />
      <BlockGrid base={base} token={token} block_types={block_types} blocks={blocks} version={version} emptyMessage="This page has no blocks yet." />
    </Page>
  )
}
