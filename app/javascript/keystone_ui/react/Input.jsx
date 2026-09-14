import React from "react"
import { classes } from "./classes"

const Input = ({ disabled, className, ...rest }) => (
  <input {...rest} className={classes("ks-input", disabled && "ks-input-disabled", className)} />
)

export default Input
