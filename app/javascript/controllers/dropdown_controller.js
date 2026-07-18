import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.closeHandler = (event) => {
      if (!this.element.contains(event.target)) {
        this.close()
      }
    }
  }

  toggle(event) {
    event.stopPropagation()
    const isActive = this.element.classList.contains("is-active")
    if (isActive) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.element.classList.add("is-active")
    document.addEventListener("click", this.closeHandler)
  }

  close() {
    this.element.classList.remove("is-active")
    document.removeEventListener("click", this.closeHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.closeHandler)
  }
}
