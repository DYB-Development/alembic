import React from "react"

const Alert = ({ type = "info" }) => <div className={`ks-alert ks-alert-${type}`} role="alert" />

export default Alert
