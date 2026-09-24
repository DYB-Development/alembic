import { test } from "node:test"
import assert from "node:assert/strict"
import { readFileSync } from "node:fs"

const REACTS_OWN = "Minified React error"

const built = (name) => readFileSync(new URL(`../../app/assets/builds/alembic/${name}`, import.meta.url), "utf8")

test("alembic's scripts carry no React of their own", () => {
  assert.deepEqual(
    [ "page_builder.js" ].filter((name) => built(name).includes(REACTS_OWN)),
    []
  )
})
