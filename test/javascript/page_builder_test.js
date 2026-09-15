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

test("shows the page's name and All pages in keystone's page header", () => {
  assert.match(render({ pages: "/pages" }), /<div class="ks-page-header"><div><h1 class="ks-page-header-title">Welcome<\/h1><\/div><div class="page-header-actions ks-page-header-actions"><a[^>]*>All pages<\/a><\/div><\/div>/)
})

test("lays the screen out in keystone's page", () => {
  assert.match(render({}), /^<div class="ks-page">/)
})
