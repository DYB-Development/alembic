import { createRoot } from "react-dom/client"
import { register, mountAll } from "keystone_ui-react/src/registry.js"
import Canvas from "./canvas/Canvas"

register("alembic/flow-editor", Canvas)

const start = () => mountAll(document, createRoot)

document.readyState === "loading" ? document.addEventListener("DOMContentLoaded", start) : start()
