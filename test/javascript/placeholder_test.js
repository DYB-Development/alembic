import { test } from "node:test"
import assert from "node:assert/strict"
import Placeholder from "../../app/javascript/alembic/canvas/Placeholder.jsx"

const spot = (dragging) => Placeholder({
  node: { id: "gate-yes", label: "yes" }, dragging, onFill: () => {}, onDrop: () => {}
})

test("colors an empty result spot amber", () => {
  assert.ok(spot(false).props.className?.split(" ").includes("border-amber-500"))
})
