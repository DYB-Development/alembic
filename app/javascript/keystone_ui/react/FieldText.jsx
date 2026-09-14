import React from "react"
import { classes } from "./classes"

const keystoneText = (Tag, keystoneClass) => ({ className, children, ...rest }) => (
  <Tag {...rest} className={classes(keystoneClass, className)}>{children}</Tag>
)

export const Label = keystoneText("label", "ks-label")
export const Hint = keystoneText("p", "ks-hint")
export const FieldError = keystoneText("p", "ks-error")
