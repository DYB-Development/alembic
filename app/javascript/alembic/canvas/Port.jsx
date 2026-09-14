import React from "react"

const open = "border border-amber-500 bg-white text-amber-700 dark:bg-zinc-900 dark:text-amber-400"

const Port = ({ name, connected, armed, onArm, connecting }) => (
  <button onClick={(event) => { if (connecting) return; event.stopPropagation(); onArm(event) }}
          title={armed ? "Now choose a step to connect to" : "Connect this branch"}
          className={armed || connected ? undefined : open}
          style={{
            padding: "1px 8px", marginRight: 4, borderRadius: 999, fontSize: 11, cursor: "pointer",
            ...(armed ? { border: "1px solid #2563eb", background: "#2563eb", color: "#fff" }
              : connected ? { border: "1px solid #d1d5db", background: "#fff", color: "#6b7280" } : {})
          }}>{name || "next"}</button>
)

export default Port
