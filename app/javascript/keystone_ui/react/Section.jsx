import React from "react"
import { classes } from "./classes"

const Section = ({ title, subtitle, action, spacing = "md", className, children }) => (
  <div className={classes(`ks-section-${spacing}`, className)}>
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
