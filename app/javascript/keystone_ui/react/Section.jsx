import React from "react"

const Section = ({ spacing = "md", children }) => <div className={`ks-section-${spacing}`}>{children}</div>

export default Section
