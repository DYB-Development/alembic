import { test } from "node:test"
import assert from "node:assert/strict"
import { register, mountAll } from "../../../../app/javascript/keystone_ui/react/registry.js"

const recordingRoots = () => {
  const rendered = []
  const createRoot = (element) => ({ render: (tree) => rendered.push({ element, tree }) })
  return { rendered, createRoot }
}

const pageWith = (...elements) => ({ querySelectorAll: () => elements })

const uiElement = (name, props) => ({ dataset: { reactUi: name, props: JSON.stringify(props) } })

test("renders a registered UI into its element with the props the element carries", () => {
  const Greeting = () => null
  register("test/greeting", Greeting)
  const { rendered, createRoot } = recordingRoots()

  mountAll(pageWith(uiElement("test/greeting", { name: "Ada" })), createRoot)

  assert.deepEqual(rendered.map(({ tree }) => [ tree.type, tree.props ]), [ [ Greeting, { name: "Ada" } ] ])
})
