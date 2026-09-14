import React from "react"
import { classes } from "./classes"

const Panel = ({ as: Tag = "div", className, children }) => (
  <Tag className={classes("ks-panel", className)}>{children}</Tag>
)

export default Panel
