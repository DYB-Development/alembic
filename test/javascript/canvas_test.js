import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Canvas from "../../app/javascript/alembic/canvas/Canvas.jsx"

const drawn = (nodes = []) => renderToStaticMarkup(React.createElement(Canvas, {
  base: "/flows/1/canvas", token: "t",
  initial: { nodes, edges: [], violations: [], palette: [], undoable: false, redoable: false, flow: {} }
}))

test("writes the editor's text in keystone's text color", () => {
  assert.match(drawn(), /^<div class="text-gray-900 dark:text-gray-100"/)
})

test("sets the canvas on the palette's surface color", () => {
  assert.match(drawn(), /^<div[^>]*><div class="bg-surface-50 dark:bg-surface-950"/)
})
