export const addBlock = (send, type) => send("/blocks", "POST", { type })
