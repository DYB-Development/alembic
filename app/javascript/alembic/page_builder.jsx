import { createRoot } from "react-dom/client"
import "react-grid-layout/css/styles.css"
import "keystone_ui-blocks/src/block_grid.css"
import { register, mountAll } from "keystone_ui-react/src/registry.js"
import PageBuilder from "./page_builder/PageBuilder"

register("alembic/page-builder", PageBuilder)

const start = () => mountAll(document, createRoot)

document.readyState === "loading" ? document.addEventListener("DOMContentLoaded", start) : start()
