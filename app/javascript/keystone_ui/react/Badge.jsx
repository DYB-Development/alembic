import React from "react"

const Badge = ({ variant = "neutral", children }) => <span className={`ks-badge ks-badge-${variant}`}>{children}</span>

export default Badge
