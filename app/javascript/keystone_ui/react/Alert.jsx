import React from "react"

const Alert = ({ type = "info", message }) => (
  <div className={`ks-alert ks-alert-${type}`} role="alert">
    <div className="ks-alert-body">
      <div className="ks-alert-content">
        <p className="ks-alert-message">{message}</p>
      </div>
    </div>
  </div>
)

export default Alert
