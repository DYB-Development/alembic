import { createRoot } from "react-dom/client"
import "react-grid-layout/css/styles.css"
import "keystone_ui-blocks/src/block_grid.css"
import { register } from "keystone_ui-react/src/registry.js"
import { startMounting } from "keystone_ui-react/src/mounting.js"
import PageBuilder from "./page_builder/PageBuilder"

register("alembic/page-builder", PageBuilder)

startMounting(document, createRoot)
