import { Controller } from "@hotwired/stimulus"

// Multiscreen Controller
// Manages the multi-stream grid layout and channel selection
export default class extends Controller {
  static targets = ["grid"]

  connect() {
    this.updateLayout()
  }

  updateLayout() {
    const players = this.element.querySelectorAll("[data-controller='hls-player']")
    const count = players.length
    const grid = this.element.querySelector("#multiscreen-grid")

    if (!grid) return

    // Remove existing grid classes
    for (let i = 1; i <= 5; i++) {
      grid.classList.remove(`multiscreen-grid-${i}`)
    }

    grid.classList.add(`multiscreen-grid-${Math.max(count, 1)}`)
  }

  openChannelPicker() {
    // Scroll to channel picker
    const picker = this.element.querySelector(".sv-card")
    if (picker) {
      picker.scrollIntoView({ behavior: "smooth" })
    }
  }
}
