import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Textarea from "../../../../app/javascript/keystone_ui/react/Textarea.jsx"

test("is a text area with keystone's input look", () => {
  assert.equal(renderToStaticMarkup(React.createElement(Textarea, { rows: 4 })), '<textarea rows="4" class="ks-input"></textarea>')
})
