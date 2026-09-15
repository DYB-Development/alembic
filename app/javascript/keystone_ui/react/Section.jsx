import React from "react"

const Section = ({ title, subtitle, spacing = "md", children }) => (
  <div className={`ks-section-${spacing}`}>
    {title && (
      <div className="ks-section-header">
        <div>
          <h2 className="ks-section-title">{title}</h2>
          {subtitle && <p className="ks-section-subtitle">{subtitle}</p>}
        </div>
      </div>
    )}
    {children}
  </div>
)

export default Section
