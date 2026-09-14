import { test } from "node:test"
import assert from "node:assert/strict"
import Port from "../../app/javascript/alembic/canvas/Port.jsx"

const classes = (given) => (Port({ name: "yes", connected: false, armed: false, connecting: false, onArm: () => {}, ...given }).props.className || "").split(" ")

test("colors a result that leads nowhere amber", () => {
  assert.ok(classes({}).includes("border-amber-500"))
})

test("colors a connected result with keystone's muted colors", () => {
  assert.ok(classes({ connected: true }).includes("border-gray-300"))
})
