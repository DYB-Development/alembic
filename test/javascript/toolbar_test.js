import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Toolbar from "../../app/javascript/alembic/canvas/Toolbar.jsx"

const drawn = () => renderToStaticMarkup(React.createElement(Toolbar, {
  undoable: true, redoable: true, onAdd: () => {}, onUndo: () => {}, onRedo: () => {}
}))

const classesWith = (html, attribute) => (html.match(new RegExp(`<[^<>]*${attribute}[^<>]*`))?.[0].match(/class="([^"]*)"/)?.[1] || "").split(" ")

test("draws adding a step as a round keystone button", () => {
  assert.deepEqual(classesWith(drawn(), 'title="Add a step"'), [ "ks-button", "ks-button-secondary", "rounded-full" ])
})
