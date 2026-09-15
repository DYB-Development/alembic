import { test } from "node:test"
import assert from "node:assert/strict"
import Badge from "../../../../app/javascript/keystone_ui/react/Badge.jsx"

test("is keystone's neutral badge by default", () => {
  assert.equal(Badge({ children: "Active" }).props.className, "ks-badge ks-badge-neutral")
})
