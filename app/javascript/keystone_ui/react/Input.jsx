import React from "react"
import { classes } from "./classes"

const Input = ({ disabled }) => <input className={classes("ks-input", disabled && "ks-input-disabled")} />

export default Input
