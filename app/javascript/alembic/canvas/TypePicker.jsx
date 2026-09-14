import React from "react"

const TypePicker = ({ entries, at, onPick, onConnect, onDismiss }) => (
  <div className="ks-panel shadow-lg" style={{ position: "absolute", zIndex: 9, top: at.y, left: at.x, width: 210, padding: 8, borderRadius: 8 }}>
    <p className="text-gray-500 dark:text-gray-400" style={{ margin: "0 0 6px", fontSize: 11 }}>Add a step</p>
    {entries.map((entry) => (
      <button key={entry.type} className="ks-button ks-button-secondary ks-button-sm w-full mb-1.5 flex-col" onClick={() => onPick(entry)}>
        {entry.label}
        <span className="opacity-75" style={{ display: "block", fontSize: 11 }}>{entry.type}</span>
      </button>
    ))}
    {onConnect && (
      <button className="ks-button ks-button-secondary ks-button-sm w-full mb-1.5" onClick={onConnect}>Connect to a step already here</button>
    )}
    <button className="ks-button ks-button-secondary ks-button-sm w-full" onClick={onDismiss}>Cancel</button>
  </div>
)

export default TypePicker
