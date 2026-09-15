import React from "react"

const Alert = ({ type = "info", title, message, onDismiss }) => (
  <div className={`ks-alert ks-alert-${type}`} role="alert">
    <div className="ks-alert-body">
      <div className="ks-alert-content">
        {title && <p className="ks-alert-title">{title}</p>}
        <p className={title ? "ks-alert-message-titled" : "ks-alert-message"}>{message}</p>
      </div>
      {onDismiss && <button type="button" className="ks-alert-dismiss" aria-label="Dismiss" onClick={onDismiss}>×</button>}
    </div>
  </div>
)

export default Alert
