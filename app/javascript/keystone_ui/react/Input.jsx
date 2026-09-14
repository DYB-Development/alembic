import React from "react"
import { classes } from "./classes"

const Input = ({ as: Tag = "input", disabled, className, ...rest }) => (
  <Tag {...rest} disabled={disabled} className={classes("ks-input", disabled && "ks-input-disabled", className)} />
)

export default Input
