import React from "react"

const Panel = ({ as: Tag = "div", children }) => (
  <Tag className="ks-panel">{children}</Tag>
)

export default Panel
