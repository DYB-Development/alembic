import { test } from "node:test"
import assert from "node:assert/strict"
import { addBlock, dropBlock, placeBlocks, removeBlock } from "../../../app/javascript/ks_blocks/blocks.js"

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

test("placing blocks sends each block's id and grid position", () => {
  const sent = []

  placeBlocks((...request) => sent.push(request), [ { i: "b1", x: 0, y: 1, w: 12, h: 1 }, { i: "b2", x: 6, y: 0, w: 6, h: 2 } ])

  assert.deepEqual(sent, [ [ "/blocks", "PATCH", { layout: [ { id: "b1", x: 0, y: 1, w: 12, h: 1 }, { id: "b2", x: 6, y: 0, w: 6, h: 2 } ] } ] ])
})

test("placing blocks also sends each block's size", () => {
  const sent = []

  placeBlocks((...request) => sent.push(request), [ { i: "b1", x: 0, y: 1, w: 8, h: 3 } ])

  assert.deepEqual(sent, [ [ "/blocks", "PATCH", { layout: [ { id: "b1", x: 0, y: 1, w: 8, h: 3 } ] } ] ])
})

test("removing a block sends a delete for that block", () => {
  const sent = []

  removeBlock((...request) => sent.push(request), "b1")

  assert.deepEqual(sent, [ [ "/blocks/b1", "DELETE" ] ])
})

test("placing blocks sends the layout version the grid last drew", () => {
  const sent = []

  placeBlocks((...request) => sent.push(request), [ { i: "b1", x: 0, y: 1, w: 8, h: 3 } ], "v1")

  assert.equal(sent[0][2].version, "v1")
})
