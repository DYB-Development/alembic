import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Inspector from "../../app/javascript/alembic/canvas/Inspector.jsx"

const drawn = (given = {}) => renderToStaticMarkup(React.createElement(Inspector, {
  node: { id: "gate", type: "condition", label: "Gate", config: {} },
  fields: { step: "string" }, holds: {}, labels: { step: "Step" }, recordLabels: {}, choices: {},
  onSave: () => {}, onDelete: () => {}, onClose: () => {}, ...given
}))

test("is drawn as a keystone panel", () => {
  assert.match(drawn(), /^<aside class="ks-panel"/)
})
