import { test } from "node:test"
import assert from "node:assert/strict"
import { createSender } from "../../../app/javascript/ks_blocks/sender.js"

const fakeServer = () => {
  const requests = []
  let version = "v1"
  const fetch = async (url, options = {}) => {
    requests.push({ url, method: options.method, body: options.body && JSON.parse(options.body) })
    if (options.method === "PATCH") version = `v${Number(version.slice(1)) + 1}`
    return { ok: true, json: async () => (url.endsWith("/layout") ? { blocks: [], version } : {}) }
  }
  return { fetch, requests }
}

test("a change sent before the previous one finished carries the version the previous one produced", async () => {
  const server = fakeServer()
  const send = createSender({ base: "/pages/1", token: "t", fetch: server.fetch, version: "v1", onLayout: () => {}, onError: () => {} })

  await Promise.all([ send("/blocks", "PATCH", { layout: [] }), send("/blocks", "PATCH", { layout: [] }) ])

  assert.deepEqual(server.requests.filter((request) => request.method === "PATCH").map((request) => request.body.version), [ "v1", "v2" ])
})

test("a change that cannot reach the server says it was not saved", async () => {
  const errors = []
  const unreachable = async () => { throw new TypeError("Failed to fetch") }
  const send = createSender({ base: "/pages/1", token: "t", fetch: unreachable, version: "v1", onLayout: () => {}, onError: (error) => errors.push(error) })

  await send("/blocks", "PATCH", { layout: [] }).catch(() => {})

  assert.deepEqual(errors, [ "Your change was not saved because the server could not be reached." ])
})
