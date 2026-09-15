import { test } from "node:test"
import assert from "node:assert/strict"
import { addBlock } from "../../app/javascript/alembic/page_builder/blocks.js"

test("adding a block type sends its key to the page's blocks", () => {
  const sent = []

  addBlock((...request) => sent.push(request), "heading")

  assert.deepEqual(sent, [ [ "/blocks", "POST", { type: "heading" } ] ])
})
