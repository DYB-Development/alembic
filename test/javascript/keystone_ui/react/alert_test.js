import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import Alert from "../../../../app/javascript/keystone_ui/react/Alert.jsx"

const render = (props) => renderToStaticMarkup(React.createElement(Alert, props))

test("is keystone's info alert by default", () => {
  assert.match(render({ message: "Saved" }), /^<div[^>]*class="ks-alert ks-alert-info"/)
})

test("takes keystone's look for the type it is given", () => {
  assert.match(render({ type: "error", message: "Could not save" }), /^<div[^>]*class="ks-alert ks-alert-error"/)
})
