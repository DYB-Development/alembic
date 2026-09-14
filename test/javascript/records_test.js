import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Records from "../../app/javascript/alembic/canvas/Records.jsx"

const drawn = () => renderToStaticMarkup(React.createElement(Records, {
  holds: { value: "string" }, labels: { value: "Value" }, rows: [ { value: "high" } ],
  onChange: () => {}, onSettle: () => {}
}))

test("borders each record with keystone's border colors", () => {
  assert.match(drawn(), /^<div[^>]*><div class="rounded-md border border-gray-200 dark:border-zinc-700"/)
})
