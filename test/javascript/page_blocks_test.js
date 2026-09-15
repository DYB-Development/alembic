import { test } from "node:test"
import assert from "node:assert/strict"
import { addBlock, dropBlock } from "../../app/javascript/alembic/page_builder/blocks.js"

test("adding a block type sends its key to the page's blocks", () => {
  const sent = []

  addBlock((...request) => sent.push(request), "heading")

  assert.deepEqual(sent, [ [ "/blocks", "POST", { type: "heading" } ] ])
})

test("dropping a block type sends its key and the grid place it was dropped on", () => {
  const sent = []

  dropBlock((...request) => sent.push(request), "text", { x: 3, y: 2 })

  assert.deepEqual(sent, [ [ "/blocks", "POST", { type: "text", x: 3, y: 2 } ] ])
})
