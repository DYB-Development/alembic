import React from "react"

const classes = (...names) => names.filter(Boolean).join(" ")

const Panel = ({ as: Tag = "div", className, children }) => (
  <Tag className={classes("ks-panel", className)}>{children}</Tag>
)

export default Panel
