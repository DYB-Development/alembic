import React from "react"
import { classes } from "./classes"

const VARIANTS = { primary: "ks-button-primary", secondary: "ks-button-secondary", danger: "ks-button-danger" }
const SIZES = { sm: "ks-button-sm", md: "ks-button-md", lg: "ks-button-lg" }

const Button = ({ variant = "primary", size = "md", className, children, ...rest }) => {
  const Tag = rest.href ? "a" : "button"

  return <Tag {...rest} className={classes("ks-button", VARIANTS[variant], SIZES[size], className)}>{children}</Tag>
}

export default Button
