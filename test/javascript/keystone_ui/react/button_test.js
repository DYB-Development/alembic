import { test } from "node:test"
import assert from "node:assert/strict"
import Button from "../../../../app/javascript/keystone_ui/react/Button.jsx"

test("is keystone's primary button at medium size by default", () => {
  assert.equal(Button({ children: "Save" }).props.className, "ks-button ks-button-primary ks-button-md")
})

test("takes keystone's look for the variant it is given", () => {
  assert.equal(Button({ variant: "danger", children: "Delete" }).props.className, "ks-button ks-button-danger ks-button-md")
})

test("takes keystone's look for the size it is given", () => {
  assert.equal(Button({ size: "sm", children: "Add" }).props.className, "ks-button ks-button-primary ks-button-sm")
})
