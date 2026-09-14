import { test } from "node:test"
import assert from "node:assert/strict"
import Panel from "../../../../app/javascript/keystone_ui/react/Panel.jsx"

test("is keystone's panel", () => {
  assert.equal(Panel({ children: "Details" }).props.className, "ks-panel")
})

test("renders as the element it is given", () => {
  assert.equal(Panel({ as: "aside", children: "Details" }).type, "aside")
})

test("adds the extra classes it is given after keystone's", () => {
  assert.equal(Panel({ className: "shadow-lg", children: "Details" }).props.className, "ks-panel shadow-lg")
})

test("passes other props through to the element", () => {
  assert.equal(Panel({ "data-builder-panel": true, children: "Details" }).props["data-builder-panel"], true)
})
