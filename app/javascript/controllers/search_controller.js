import { Controller } from "@hotwired/stimulus"

// Search Controller with live search via Turbo Stream
export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: { type: String, default: "/contents/search" } }

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      const query = this.inputTarget.value.trim()
      if (query.length >= 2) {
        const url = `${this.urlValue}?q=${encodeURIComponent(query)}`
        fetch(url, {
          headers: {
            "Accept": "text/vnd.turbo-stream.html",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
          }
        })
        .then(response => response.text())
        .then(html => {
          Turbo.renderStreamMessage(html)
        })
      }
    }, 300)
  }

  clear() {
    this.inputTarget.value = ""
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = ""
    }
  }
}
