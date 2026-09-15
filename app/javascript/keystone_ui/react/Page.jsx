import React from "react"
import { classes } from "./classes"

const Page = ({ maxWidth = "full", padding = "standard", topOffset, children }) => (
  <div className={classes(padding !== "none" && "ks-page", topOffset && `ks-page-offset-${topOffset}`, maxWidth !== "full" && `ks-page-${maxWidth}`)}>{children}</div>
)

export default Page
