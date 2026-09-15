import React from "react"
import { classes } from "./classes"

const Badge = ({ variant = "neutral", className, children, ...rest }) => (
  <span {...rest} className={classes("ks-badge", `ks-badge-${variant}`, className)}>{children}</span>
)

export default Badge
