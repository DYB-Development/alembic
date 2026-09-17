import { createRoot } from "react-dom/client"
import { register } from "keystone_ui-react/src/registry.js"
import { startMounting } from "keystone_ui-react/src/mounting.js"
import Canvas from "./canvas/Canvas"

register("alembic/flow-editor", Canvas)

document.addEventListener("alembic:flow-named", (event) => {
  const heading = document.querySelector("[data-flow-heading]")
  if (heading) heading.textContent = event.detail
})

startMounting(document, createRoot)
