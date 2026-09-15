import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import PageHeader from "../../../../app/javascript/keystone_ui/react/PageHeader.jsx"

const render = (props) => renderToStaticMarkup(React.createElement(PageHeader, { title: "Welcome", ...props }))

test("shows its title in keystone's page header", () => {
  assert.equal(render({}), '<div class="ks-page-header"><div><h1 class="ks-page-header-title">Welcome</h1></div></div>')
})
