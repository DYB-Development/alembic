const UNREACHABLE = "Your change was not saved because the server could not be reached."

export const createSender = ({ base, token, fetch, version, onLayout, onError }) => {
  let current = version
  let queue = Promise.resolve()

  const sendNow = async (path, method, body) => {
    const response = await fetch(base + path, {
      method, headers: { "Content-Type": "application/json", "X-CSRF-Token": token }, body: body && JSON.stringify({ ...body, version: current })
    }).catch(() => null)
    if (!response) return onError(UNREACHABLE)

    const answered = await response.json().catch(() => ({}))
    onError(response.ok ? null : answered.error)
    const layout = await (await fetch(base + "/layout", { headers: { Accept: "application/json" } })).json()
    current = layout.version
    onLayout(layout)
  }

  return (path, method, body) => (queue = queue.then(() => sendNow(path, method, body)))
}
