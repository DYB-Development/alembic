export const addBlock = (send, type) => send("/blocks", "POST", { type })

export const dropBlock = (send, type, { x, y }) => send("/blocks", "POST", { type, x, y })

export const placeBlocks = (send, layout, version) => send("/blocks", "PATCH", { layout: layout.map(({ i, x, y, w, h }) => ({ id: i, x, y, w, h })), ...(version && { version }) })

export const removeBlock = (send, id) => send(`/blocks/${id}`, "DELETE")
