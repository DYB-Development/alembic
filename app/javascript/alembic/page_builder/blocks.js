export const addBlock = (send, type) => send("/blocks", "POST", { type })

export const dropBlock = (send, type, { x, y }) => send("/blocks", "POST", { type, x, y })
