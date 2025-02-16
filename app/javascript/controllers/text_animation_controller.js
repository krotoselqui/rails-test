import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  connect() {
    const text = this.contentTarget.textContent
    const chars = text.split("")
    this.contentTarget.innerHTML = chars
      .map((char, index) => {
        if (char === "\n") {
          return "<br>"
        }
        return `<span class="animate-float" style="animation-delay: ${index * 0.1}s">${char}</span>`
      })
      .join("")
  }
}