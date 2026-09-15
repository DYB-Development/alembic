import { useCallback, useState } from "react"

const usePage = (base, token, initial) => {
  const [ page, setPage ] = useState(initial)

  const send = useCallback(async (path, method, body) => {
    await fetch(base + path, {
      method, headers: { "Content-Type": "application/json", "X-CSRF-Token": token }, body: body && JSON.stringify(body)
    })
    setPage(await (await fetch(base + ".json", { headers: { Accept: "application/json" } })).json())
  }, [ base, token ])

  return { page, send }
}

export default usePage
