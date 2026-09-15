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

test("announces itself as an alert", () => {
  assert.match(render({ message: "Saved" }), /^<div[^>]*role="alert"/)
})

test("shows its message in keystone's message, inside keystone's body and content", () => {
  assert.match(render({ message: "Saved" }), /<div class="ks-alert-body"><div class="ks-alert-content"><p class="ks-alert-message">Saved<\/p><\/div><\/div>/)
})

test("shows a title above a titled message when it is given one", () => {
  assert.match(render({ title: "Error", message: "Could not save" }), /<p class="ks-alert-title">Error<\/p><p class="ks-alert-message-titled">Could not save<\/p>/)
})

test("offers keystone's dismiss button when it is given a way to be dismissed", () => {
  assert.match(render({ message: "Saved", onDismiss: () => {} }), /<button type="button" class="ks-alert-dismiss" aria-label="Dismiss">×<\/button>/)
})

test("dismissing it calls the way it was given to be dismissed", () => {
  const onDismiss = () => {}
  const found = []
  const walk = (node) => {
    if (!node || typeof node !== "object") return
    if (Array.isArray(node)) return node.forEach(walk)
    if (node.props?.["aria-label"] === "Dismiss") found.push(node)
    walk(node.props?.children)
  }

  walk(Alert({ message: "Saved", onDismiss }))

  assert.equal(found[0]?.props.onClick, onDismiss)
})
