import React from "react"

const registered = new Map()

export const register = (name, component) => registered.set(name, component)

export const mountAll = (page, createRoot) =>
  page.querySelectorAll("[data-react-ui]").forEach((element) => {
    const Component = registered.get(element.dataset.reactUi)
    createRoot(element).render(React.createElement(Component, JSON.parse(element.dataset.props)))
  })
