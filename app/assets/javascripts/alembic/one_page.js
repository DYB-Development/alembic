(() => {
  const start = (form) => {
    if (form.dataset.onePageStarted) return
    form.dataset.onePageStarted = "true"

    const questions = Array.from(form.querySelectorAll("[data-one-page-question]"))
    const ready = form.querySelector("[data-one-page-ready]")
    const show = (index) => {
      questions.forEach((question, position) => { question.hidden = position !== index })
      ready.hidden = index < questions.length
    }

    show(0)
  }

  const begin = () => document.querySelectorAll("form[data-one-page]").forEach(start)

  document.addEventListener("turbo:load", begin)
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", begin)
  } else {
    begin()
  }
})()
