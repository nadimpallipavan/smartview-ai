import { Controller } from "@hotwired/stimulus"

// Carousel / horizontal scroll row controller
export default class extends Controller {
  static targets = ["track"]

  scrollLeft() {
    this.trackTarget.scrollBy({ left: -400, behavior: "smooth" })
  }

  scrollRight() {
    this.trackTarget.scrollBy({ left: 400, behavior: "smooth" })
  }
}
