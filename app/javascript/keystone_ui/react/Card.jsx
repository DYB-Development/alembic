import React from "react"
import { classes } from "./classes"

const Card = ({ title, summary, link, cta = "Read more", edgeToEdge = false, className }) => (
  <div className={classes(edgeToEdge ? "ks-card-edge" : "ks-card", className)}>
    <div className="ks-card-body">
      <h3 className="ks-card-title">{title}</h3>
      <p className="ks-card-summary">{summary}</p>
    </div>
    <div className="ks-card-cta">
      <a href={link} className="ks-card-link">{cta}</a>
    </div>
  </div>
)

export default Card
