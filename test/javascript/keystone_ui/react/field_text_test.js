import { test } from "node:test"
import assert from "node:assert/strict"
import React from "react"
import { renderToStaticMarkup } from "react-dom/server"
import { Label, Hint, FieldError, Required } from "../../../../app/javascript/keystone_ui/react/FieldText.jsx"

const drawn = (component, props = {}, text = "Title") => renderToStaticMarkup(React.createElement(component, props, text))

test("a label is keystone's field label", () => {
  assert.equal(drawn(Label), '<label class="ks-label">Title</label>')
})

test("a label keeps its extra classes and other props", () => {
  assert.equal(drawn(Label, { className: "mb-1", htmlFor: "title" }), '<label for="title" class="ks-label mb-1">Title</label>')
})

test("a hint is keystone's field hint", () => {
  assert.equal(drawn(Hint, {}, "Shown to visitors"), '<p class="ks-hint">Shown to visitors</p>')
})

test("an error is keystone's field error", () => {
  assert.equal(drawn(FieldError, {}, "can't be blank"), '<p class="ks-error">can&#x27;t be blank</p>')
})

test("a required marker is keystone's asterisk", () => {
  assert.equal(renderToStaticMarkup(React.createElement(Required)), '<span class="ks-required">*</span>')
})
