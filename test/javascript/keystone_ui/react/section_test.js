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
