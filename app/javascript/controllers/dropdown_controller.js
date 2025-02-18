import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "menu" ]

  connect() {
    document.addEventListener('click', this.closeMenu.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.closeMenu.bind(this))
  }

  toggleMenu(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle('hidden')
  }

  closeMenu(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add('hidden')
    }
  }
}