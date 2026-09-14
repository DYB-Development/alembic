import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Connector from "../../app/javascript/alembic/canvas/Connector.jsx"

const drawn = () => renderToStaticMarkup(React.createElement(Connector, {
  link: { source: "a", target: "b", midX: 100, midY: 100 }, dragging: false,
  onInsert: () => {}, onRemove: () => {}, onDrop: () => {}
}))

const classesWith = (html, attribute) => (html.match(new RegExp(`<[^<>]*${attribute}[^<>]*`))?.[0].match(/class="([^"]*)"/)?.[1] || "").split(" ")

test("offers inserting a step as a round keystone button", () => {
  assert.ok(classesWith(drawn(), 'title="Insert a step here"').includes("rounded-full"))
})
