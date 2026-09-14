import React from "react"
import { action } from "./styles"

const TypePicker = ({ entries, at, onPick, onConnect, onDismiss }) => (
  <div className="ks-panel shadow-lg" style={{ position: "absolute", zIndex: 9, top: at.y, left: at.x, width: 210, padding: 8, borderRadius: 8 }}>
    <p style={{ margin: "0 0 6px", fontSize: 11, color: "#6b7280" }}>Add a step</p>
    {entries.map((entry) => (
      <button key={entry.type} style={action} onClick={() => onPick(entry)}>
        {entry.label}
        <span style={{ display: "block", color: "#6b7280", fontSize: 11 }}>{entry.type}</span>
      </button>
    ))}
    {onConnect && (
      <button style={{ ...action, textAlign: "center" }} onClick={onConnect}>Connect to a step already here</button>
    )}
    <button style={{ ...action, textAlign: "center", marginBottom: 0 }} onClick={onDismiss}>Cancel</button>
  </div>
)

export default TypePicker
