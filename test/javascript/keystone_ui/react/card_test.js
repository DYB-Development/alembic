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

test("shows its title and summary in keystone's body", () => {
  assert.match(render({}), /<div class="ks-card-body"><h3 class="ks-card-title">Revenue<\/h3><p class="ks-card-summary">\$42k<\/p><\/div>/)
})

test("links to its address with Read more by default", () => {
  assert.match(render({}), /<div class="ks-card-cta"><a href="\/reports" class="ks-card-link">Read more<\/a><\/div>/)
})
