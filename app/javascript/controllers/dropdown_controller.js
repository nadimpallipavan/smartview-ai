import { Controller } from "@hotwired/stimulus"

// Dropdown / modal toggle controller
export default class extends Controller {
  static targets = ["menu"]
  static values = { open: { type: Boolean, default: false } }

  toggle() {
    this.openValue = !this.openValue
    this.menuTarget.classList.toggle("hidden", !this.openValue)
  }

  close() {
    this.openValue = false
    this.menuTarget.classList.add("hidden")
  }

  // Close on outside click
  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
