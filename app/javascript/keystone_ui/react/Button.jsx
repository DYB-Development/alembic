import React from "react"

const VARIANTS = { primary: "ks-button-primary", secondary: "ks-button-secondary", danger: "ks-button-danger" }

const Button = ({ variant = "primary", children }) => (
  <button className={`ks-button ${VARIANTS[variant]} ks-button-md`}>{children}</button>
)

export default Button
