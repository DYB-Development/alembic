import React from "react"
import { classes } from "./classes"

const PageHeader = ({ title, subtitle, actions, className }) => (
  <div className={classes("ks-page-header", className)}>
    <div>
      <h1 className="ks-page-header-title">{title}</h1>
      {subtitle && <p className="ks-page-header-subtitle">{subtitle}</p>}
    </div>
    {actions && <div className="page-header-actions ks-page-header-actions">{actions}</div>}
  </div>
)

export default PageHeader
