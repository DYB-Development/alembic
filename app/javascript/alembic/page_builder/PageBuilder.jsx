import React from "react"
import Button from "../../keystone_ui/react/Button"
import Panel from "../../keystone_ui/react/Panel"

export default function PageBuilder({ name, pages }) {
  return (
    <div>
      <h1>{name}</h1>
      <Button href={pages} data-all-pages>All pages</Button>
      <Panel data-page-panel>
        <p>This page has no blocks yet.</p>
      </Panel>
    </div>
  )
}
