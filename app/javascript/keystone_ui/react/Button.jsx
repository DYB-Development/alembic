import React from "react"

const VARIANTS = { primary: "ks-button-primary", secondary: "ks-button-secondary", danger: "ks-button-danger" }
const SIZES = { sm: "ks-button-sm", md: "ks-button-md", lg: "ks-button-lg" }

const classes = (...names) => names.filter(Boolean).join(" ")

const Button = ({ variant = "primary", size = "md", className, children, ...rest }) => (
  <button {...rest} className={classes("ks-button", VARIANTS[variant], SIZES[size], className)}>{children}</button>
)

export default Button
