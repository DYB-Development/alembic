import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Section from "../../../../app/javascript/keystone_ui/react/Section.jsx"

const render = (props) => renderToStaticMarkup(React.createElement(Section, props))

test("takes keystone's medium spacing by default", () => {
  assert.match(render({}), /^<div class="ks-section-md">/)
})

test("takes keystone's spacing for the size it is given", () => {
  assert.match(render({ spacing: "lg" }), /^<div class="ks-section-lg">/)
})

test("shows its content", () => {
  assert.match(render({ children: React.createElement("p", null, "Rows") }), /<p>Rows<\/p><\/div>$/)
})

test("shows its title in keystone's header when it is given one", () => {
  assert.match(render({ title: "Blocks" }), /^<div class="ks-section-md"><div class="ks-section-header"><div><h2 class="ks-section-title">Blocks<\/h2><\/div><\/div>/)
})

test("shows a subtitle under its title when it is given one", () => {
  assert.match(render({ title: "Blocks", subtitle: "Drag one onto the page" }), /<h2 class="ks-section-title">Blocks<\/h2><p class="ks-section-subtitle">Drag one onto the page<\/p>/)
})

test("links its action beside the title when it is given one", () => {
  assert.match(render({ title: "Blocks", action: { label: "View all", href: "/blocks" } }), /<\/div><a href="\/blocks" class="ks-section-action">View all<\/a><\/div>/)
})

test("adds the extra classes it is given after keystone's", () => {
  assert.match(render({ className: "px-2" }), /^<div class="ks-section-md px-2">/)
})
