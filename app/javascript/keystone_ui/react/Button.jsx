import React from "react"

const VARIANTS = { primary: "ks-button-primary", secondary: "ks-button-secondary", danger: "ks-button-danger" }
const SIZES = { sm: "ks-button-sm", md: "ks-button-md", lg: "ks-button-lg" }

const Button = ({ variant = "primary", size = "md", children }) => (
  <button className={`ks-button ${VARIANTS[variant]} ${SIZES[size]}`}>{children}</button>
)

export default Button
