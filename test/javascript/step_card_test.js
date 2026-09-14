import { test } from "node:test"
import assert from "node:assert/strict"
import StepCard from "../../app/javascript/alembic/canvas/StepCard.jsx"

const card = (node = {}, given = {}) => StepCard({
  node: { id: "gate", label: "Gate", type: "condition", violations: [], ports: [], connected: [], ...node },
  selected: false, armed: null, connecting: false,
  onSelect: () => {}, onArm: () => {}, onDragEnd: () => {}, onDragStart: () => {}, ...given
})

const classes = (element) => (element.props.className || "").split(" ")

test("sets the card on keystone's panel background", () => {
  assert.ok(classes(card()).includes("bg-white"))
})

test("borders an ordinary card in keystone's border color", () => {
  assert.ok(classes(card()).includes("border-gray-300"))
})
