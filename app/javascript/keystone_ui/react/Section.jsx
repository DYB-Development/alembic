import React from "react"

const Section = ({ title, subtitle, action, spacing = "md", children }) => (
  <div className={`ks-section-${spacing}`}>
    {title && (
      <div className="ks-section-header">
        <div>
          <h2 className="ks-section-title">{title}</h2>
          {subtitle && <p className="ks-section-subtitle">{subtitle}</p>}
        </div>
        {action && <a href={action.href} className="ks-section-action">{action.label}</a>}
      </div>
    )}
    {children}
  </div>
)

export default Section
