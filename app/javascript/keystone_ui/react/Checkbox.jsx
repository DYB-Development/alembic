import React from "react"
import { classes } from "./classes"

const Checkbox = ({ className, ...rest }) => (
  <input type="checkbox" {...rest} className={classes("ks-checkbox", className)} />
)

export default Checkbox
