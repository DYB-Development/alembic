import React, { useState } from "react"
import { plus } from "./styles"

const round = { width: 24, height: 24, padding: 0, fontSize: 15, lineHeight: "15px" }

const Connector = ({ link, onInsert, onRemove, onDrop, dragging }) => {
  const [ over, setOver ] = useState(false)
  const showing = over || dragging

  return (
    <div data-connector={`${link.source}-${link.target}`}
         style={{ position: "absolute", left: link.midX - 34, top: link.midY - 20, width: 68, height: 40, zIndex: 4 }}
         onMouseEnter={() => setOver(true)} onMouseLeave={() => setOver(false)}
         onDragEnter={() => setOver(true)} onDragLeave={() => setOver(false)}
         onDragOver={(event) => { event.preventDefault(); event.dataTransfer.dropEffect = "move" }}
         onDrop={(event) => { event.preventDefault(); setOver(false); onDrop() }}>
      <div style={{ display: "flex", gap: 4, justifyContent: "center", alignItems: "center", height: "100%",
                    opacity: showing ? 1 : 0, transition: "opacity .12s" }}>
        <button title={dragging ? "Move the step here" : "Insert a step here"} onClick={onInsert}
                className="ks-button ks-button-secondary rounded-full" style={round}>+</button>
        {!dragging && (
          <button title="Remove this connection" onClick={onRemove}
                  style={{ ...plus, color: "#dc2626", borderColor: "#e5b4b4" }}>×</button>
        )}
      </div>
    </div>
  )
}

export default Connector
