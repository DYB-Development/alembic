import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import PageHeader from "../../../../app/javascript/keystone_ui/react/PageHeader.jsx"

const render = (props) => renderToStaticMarkup(React.createElement(PageHeader, { title: "Welcome", ...props }))

test("shows its title in keystone's page header", () => {
  assert.equal(render({}), '<div class="ks-page-header"><div><h1 class="ks-page-header-title">Welcome</h1></div></div>')
})

test("shows a subtitle under its title when it is given one", () => {
  assert.match(render({ subtitle: "Build your page" }), /<h1 class="ks-page-header-title">Welcome<\/h1><p class="ks-page-header-subtitle">Build your page<\/p>/)
})

test("shows its actions in keystone's actions area when it is given some", () => {
  assert.match(render({ actions: React.createElement("a", { href: "/pages" }, "All pages") }), /<\/div><div class="page-header-actions ks-page-header-actions"><a href="\/pages">All pages<\/a><\/div><\/div>$/)
})

test("adds the extra classes it is given after keystone's", () => {
  assert.match(render({ className: "mb-2" }), /^<div class="ks-page-header mb-2">/)
})
