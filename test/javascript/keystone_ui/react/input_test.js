import { test } from "node:test"
import assert from "node:assert/strict"
import Input from "../../../../app/javascript/keystone_ui/react/Input.jsx"

test("is keystone's input", () => {
  assert.equal(Input({}).props.className, "ks-input")
})
