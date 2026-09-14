import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import { Label } from "../../../../app/javascript/keystone_ui/react/FieldText.jsx"

const drawn = (component, props = {}, text = "Title") => renderToStaticMarkup(React.createElement(component, props, text))

test("a label is keystone's field label", () => {
  assert.equal(drawn(Label), '<label class="ks-label">Title</label>')
})

test("a label keeps its extra classes and other props", () => {
  assert.equal(drawn(Label, { className: "mb-1", htmlFor: "title" }), '<label for="title" class="ks-label mb-1">Title</label>')
})
