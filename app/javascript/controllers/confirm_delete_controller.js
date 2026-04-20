import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "input", "confirmButton"]
  static values = { name: String }

  open() {
    this.inputTarget.value = ""
    this.confirmButtonTarget.disabled = true
    this.modalTarget.classList.add("is-active")
    this.inputTarget.focus()
  }

  close() {
    this.modalTarget.classList.remove("is-active")
  }

  validate() {
    this.confirmButtonTarget.disabled =
      this.inputTarget.value.trim() !== this.nameValue
  }
}
