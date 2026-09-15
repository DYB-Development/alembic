import { useCallback, useState } from "react"

const useLayout = (base, token, initial) => {
  const [ layout, setLayout ] = useState(initial)

  const send = useCallback(async (path, method, body) => {
    await fetch(base + path, {
      method, headers: { "Content-Type": "application/json", "X-CSRF-Token": token }, body: body && JSON.stringify(body)
    })
    setLayout(await (await fetch(base + "/layout", { headers: { Accept: "application/json" } })).json())
  }, [ base, token ])

  return { layout, send }
}

export default useLayout
