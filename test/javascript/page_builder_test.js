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

test("links to the page list as its primary button", () => {
  assert.match(render({ pages: "/pages" }), /<a[^>]*href="\/pages"[^>]*class="[^"]*ks-button-primary[^"]*"[^>]*>All pages<\/a>/)
})

test("shows the page in a keystone panel", () => {
  assert.match(render({}).match(/<div[^>]*data-page-panel[^>]*>/)?.[0] ?? "", /class="[^"]*ks-panel/)
})

test("lists exactly the block types it is given, by name", () => {
  const markup = render({ block_types: [ { key: "heading", name: "Heading", width: 12, height: 1 }, { key: "text", name: "Text", width: 6, height: 2 } ] })

  assert.deepEqual([ ...markup.matchAll(/<[^>]*data-block-type[^>]*>([^<]*)</g) ].map((found) => found[1]), [ "Heading", "Text" ])
})

test("says there are no blocks to add when it is given no block types", () => {
  assert.match(render({ block_types: [] }), /There are no blocks to add/)
})

test("draws each block on the grid by its type's name", () => {
  const markup = render({
    block_types: [ { key: "heading", name: "Heading", width: 12, height: 1 } ],
    blocks: [ { id: "b1", type: "heading", x: 0, y: 0, w: 12, h: 1 } ]
  })

  assert.match(markup, /<[^>]*data-block="b1"[^>]*>[^<]*Heading/)
})

test("does not say the page has no blocks once it has one", () => {
  const markup = render({
    block_types: [ { key: "heading", name: "Heading", width: 12, height: 1 } ],
    blocks: [ { id: "b1", type: "heading", x: 0, y: 0, w: 12, h: 1 } ]
  })

  assert.doesNotMatch(markup, /This page has no blocks yet/)
})

test("offers an Add button beside each block type", () => {
  const markup = render({ block_types: [ { key: "heading", name: "Heading", width: 12, height: 1 } ] })

  assert.match(markup, /<li[^>]*data-block-type="heading"[^>]*>.*<button[^>]*>Add<\/button>.*<\/li>/)
})

test("lets each block type be dragged", () => {
  const markup = render({ block_types: [ { key: "heading", name: "Heading", width: 12, height: 1 } ] })

  assert.match(markup.match(/<li[^>]*data-block-type="heading"[^>]*>/)?.[0] ?? "", /draggable="true"/)
})

test("shows the page's name and All pages in keystone's page header", () => {
  assert.match(render({ pages: "/pages" }), /<div class="ks-page-header"><div><h1 class="ks-page-header-title">Welcome<\/h1><\/div><div class="page-header-actions ks-page-header-actions"><a[^>]*>All pages<\/a><\/div><\/div>/)
})

test("lays the screen out in keystone's page", () => {
  assert.match(render({}), /^<div class="ks-page">/)
})

test("lists the block types in their own keystone section titled Blocks", () => {
  const markup = render({ block_types: [ { key: "heading", name: "Heading", width: 12, height: 1 } ] })

  assert.match(markup, /<h2 class="ks-section-title">Blocks<\/h2><\/div><\/div><ul[^>]*><li[^>]*data-block-type="heading"/)
})

test("draws each block on the grid as a keystone panel", () => {
  const markup = render({
    block_types: [ { key: "heading", name: "Heading", width: 12, height: 1 } ],
    blocks: [ { id: "b1", type: "heading", x: 0, y: 0, w: 12, h: 1 } ]
  })

  assert.match(markup.match(/<div[^>]*data-block="b1"[^>]*>/)?.[0] ?? "", /class="[^"]*ks-panel/)
})

test("keeps blocks inside the grid so the page never scrolls sideways", () => {
  assert.match(render({}).match(/<div[^>]*data-page-grid[^>]*>/)?.[0] ?? "", /overflow:hidden/)
})
