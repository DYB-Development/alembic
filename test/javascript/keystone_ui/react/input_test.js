import { test } from "node:test"
import assert from "node:assert/strict"
import Input from "../../../../app/javascript/keystone_ui/react/Input.jsx"

test("is keystone's input", () => {
  assert.equal(Input({}).props.className, "ks-input")
})

test("takes keystone's disabled look when it is disabled", () => {
  assert.equal(Input({ disabled: true }).props.className, "ks-input ks-input-disabled")
})

test("adds the extra classes it is given after keystone's", () => {
  assert.equal(Input({ className: "mb-3" }).props.className, "ks-input mb-3")
})
