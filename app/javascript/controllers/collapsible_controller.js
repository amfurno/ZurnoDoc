import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = { key: String, expanded: { type: Boolean, default: true } }

  connect() {
    const stored = localStorage.getItem(this.storageKey)
    if (stored !== null) {
      this.expandedValue = stored === "true"
    }
    this.applyState()
  }

  toggle() {
    this.expandedValue = !this.expandedValue
    localStorage.setItem(this.storageKey, this.expandedValue)
    this.applyState()
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  applyState() {
    if (this.expandedValue) {
      this.contentTarget.classList.remove("is-hidden")
      this.iconTarget.textContent = "−"
    } else {
      this.contentTarget.classList.add("is-hidden")
      this.iconTarget.textContent = "+"
    }
  }

  get storageKey() {
    return `collapsible-${this.keyValue}`
  }
}
