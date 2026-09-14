import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Select from "../../../../app/javascript/keystone_ui/react/Select.jsx"

test("is a select with keystone's input look around its options", () => {
  const select = React.createElement(Select, { defaultValue: "a" }, React.createElement("option", { value: "a" }, "Budget?"))

  assert.equal(renderToStaticMarkup(select), '<select class="ks-input"><option value="a" selected="">Budget?</option></select>')
})
