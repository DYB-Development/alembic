import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import PageBuilder from "../../app/javascript/alembic/page_builder/PageBuilder.jsx"

const render = (props) => renderToStaticMarkup(React.createElement(PageBuilder, { base: "/pages/1", name: "Welcome", ...props }))

test("shows the page's name", () => {
  assert.match(render({}), /Welcome/)
})

test("says the page has no blocks yet", () => {
  assert.match(render({}), /This page has no blocks yet/)
})
