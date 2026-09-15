import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Card from "../../../../app/javascript/keystone_ui/react/Card.jsx"

const render = (props) => renderToStaticMarkup(React.createElement(Card, { title: "Revenue", summary: "$42k", link: "/reports", ...props }))

test("is keystone's card by default", () => {
  assert.match(render({}), /^<div class="ks-card">/)
})

test("runs edge to edge on small screens when asked", () => {
  assert.match(render({ edgeToEdge: true }), /^<div class="ks-card-edge">/)
})
