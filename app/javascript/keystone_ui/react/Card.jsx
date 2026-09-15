import React from "react"

const Card = ({ title, summary, link, edgeToEdge = false }) => (
  <div className={edgeToEdge ? "ks-card-edge" : "ks-card"}>
    <div className="ks-card-body">
      <h3 className="ks-card-title">{title}</h3>
      <p className="ks-card-summary">{summary}</p>
    </div>
    <div className="ks-card-cta">
      <a href={link} className="ks-card-link">Read more</a>
    </div>
  </div>
)

export default Card
