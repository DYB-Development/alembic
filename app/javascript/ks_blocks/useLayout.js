import { useCallback, useState } from "react"

const useLayout = (base, token, initial) => {
  const [ layout, setLayout ] = useState(initial)
  const [ error, setError ] = useState(null)

  const send = useCallback(async (path, method, body) => {
    const response = await fetch(base + path, {
      method, headers: { "Content-Type": "application/json", "X-CSRF-Token": token }, body: body && JSON.stringify(body)
    })
    const answered = await response.json().catch(() => ({}))
    setError(response.ok ? null : answered.error)
    setLayout(await (await fetch(base + "/layout", { headers: { Accept: "application/json" } })).json())
  }, [ base, token ])

  return { layout, error, send }
}

export default useLayout
