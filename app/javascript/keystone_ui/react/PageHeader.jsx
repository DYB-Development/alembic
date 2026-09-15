import React from "react"

const PageHeader = ({ title, subtitle }) => (
  <div className="ks-page-header">
    <div>
      <h1 className="ks-page-header-title">{title}</h1>
      {subtitle && <p className="ks-page-header-subtitle">{subtitle}</p>}
    </div>
  </div>
)

export default PageHeader
