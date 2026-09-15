import React from "react"
import { classes } from "./classes"

const Page = ({ maxWidth = "full", children }) => (
  <div className={classes("ks-page", maxWidth !== "full" && `ks-page-${maxWidth}`)}>{children}</div>
)

export default Page
