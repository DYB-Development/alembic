import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Checkbox from "../../../../app/javascript/keystone_ui/react/Checkbox.jsx"

test("is a checkbox with keystone's checkbox look", () => {
  assert.match(renderToStaticMarkup(React.createElement(Checkbox, { defaultChecked: true })), /^<input type="checkbox"[^>]* class="ks-checkbox"/)
})
