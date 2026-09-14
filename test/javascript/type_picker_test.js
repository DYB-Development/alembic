import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import TypePicker from "../../app/javascript/alembic/canvas/TypePicker.jsx"

const drawn = () => renderToStaticMarkup(React.createElement(TypePicker, {
  entries: [ { type: "question", label: "Question" } ], at: { x: 0, y: 0 },
  onPick: () => {}, onConnect: () => {}, onDismiss: () => {}
}))

test("is drawn as a keystone panel", () => {
  assert.match(drawn(), /^<div class="ks-panel shadow-lg"/)
})

const classesOf = (html, text) => (html.match(new RegExp(`<[^<>]*class="([^"]*)"[^<>]*>${text}`))?.[1] || "").split(" ")

test("writes its caption in keystone's muted text color", () => {
  assert.ok(classesOf(drawn(), "Add a step").includes("text-gray-500"))
})
