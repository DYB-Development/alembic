import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import { Label } from "../../../../app/javascript/keystone_ui/react/FieldText.jsx"

const drawn = (component, props = {}, text = "Title") => renderToStaticMarkup(React.createElement(component, props, text))

test("a label is keystone's field label", () => {
  assert.equal(drawn(Label), '<label class="ks-label">Title</label>')
})
