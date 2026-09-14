import { test } from "node:test"
import assert from "node:assert/strict"
import Button from "../../../../app/javascript/keystone_ui/react/Button.jsx"

test("is keystone's primary button at medium size by default", () => {
  assert.equal(Button({ children: "Save" }).props.className, "ks-button ks-button-primary ks-button-md")
})
