import { test } from "node:test"
import assert from "node:assert/strict"
import { readdirSync, readFileSync } from "node:fs"

const directory = new URL("../../../../app/javascript/keystone_ui/react/", import.meta.url)

const outsideImports = () => readdirSync(directory).flatMap((file) =>
  [ ...readFileSync(new URL(file, directory), "utf8").matchAll(/from "([^"]+)"/g) ]
    .map((match) => match[1])
    .filter((source) => source !== "react" && !source.startsWith("./"))
    .map((source) => `${file} imports ${source}`)
)

test("the keystone controls import nothing but React and each other", () => {
  assert.deepEqual(outsideImports(), [])
})
