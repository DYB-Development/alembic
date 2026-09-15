import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Page from "../../../../app/javascript/keystone_ui/react/Page.jsx"

const render = (props) => renderToStaticMarkup(React.createElement(Page, { children: "Content", ...props }))

test("wraps its content in keystone's page padding by default", () => {
  assert.equal(render({}), '<div class="ks-page">Content</div>')
})

test("takes keystone's centered width for the maximum width it is given", () => {
  assert.match(render({ maxWidth: "md" }), /^<div class="ks-page ks-page-md">/)
})

test("takes keystone's space above for the top offset it is given", () => {
  assert.match(render({ topOffset: "sm" }), /^<div class="ks-page ks-page-offset-sm">/)
})
