import { Controller } from "@hotwired/stimulus"

// Webcam Capture Controller for Face Enrollment and Recognition
// Uses getUserMedia to capture frames from the webcam
export default class extends Controller {
  static targets = ["video", "canvas", "preview", "captureButton", "status", "imageData"]
  static values = {
    mode: { type: String, default: "enroll" }, // "enroll" or "recognize"
    profileId: Number,
    autoCapture: { type: Boolean, default: false }
  }

  connect() {
    this.stream = null
    this.startCamera()
  }

  disconnect() {
    this.stopCamera()
  }

  async startCamera() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { ideal: 640 },
          height: { ideal: 480 },
          facingMode: "user"
        }
      })
      this.videoTarget.srcObject = this.stream
      this.videoTarget.play()
      this.updateStatus("Camera active — position your face in the frame", "info")

      if (this.autoCaptureValue) {
        // Auto-capture after 3 seconds for recognition mode
        setTimeout(() => this.capture(), 3000)
      }
    } catch (error) {
      console.error("Camera error:", error)
      this.updateStatus("Camera access denied. Please enable camera permissions.", "error")
    }
  }

  stopCamera() {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
      this.stream = null
    }
  }

  capture() {
    const video = this.videoTarget
    const canvas = this.canvasTarget

    canvas.width = video.videoWidth
    canvas.height = video.videoHeight

    const ctx = canvas.getContext("2d")
    ctx.drawImage(video, 0, 0)

    // Get image as base64
    const imageData = canvas.toDataURL("image/jpeg", 0.9)

    // Show preview
    if (this.hasPreviewTarget) {
      this.previewTarget.src = imageData
      this.previewTarget.classList.remove("hidden")
    }

    // Set hidden field value
    if (this.hasImageDataTarget) {
      this.imageDataTarget.value = imageData
    }

    if (this.modeValue === "recognize") {
      this.sendForRecognition(imageData)
    } else {
      this.updateStatus("Photo captured! Click 'Enroll Face' to save.", "success")
    }
  }

  async sendForRecognition(imageData) {
    this.updateStatus("Recognizing face...", "info")

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const formData = new FormData()
      // Convert base64 to blob
      const response = await fetch(imageData)
      const blob = await response.blob()
      formData.append("face_image", blob, "capture.jpg")

      const result = await fetch("/recognize_face", {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "text/vnd.turbo-stream.html, application/json"
        },
        body: formData
      })

      if (result.ok) {
        const contentType = result.headers.get("content-type")
        if (contentType && contentType.includes("turbo-stream")) {
          const html = await result.text()
          Turbo.renderStreamMessage(html)
          this.updateStatus("Face recognized!", "success")
        } else {
          const data = await result.json()
          if (data.success) {
            this.updateStatus(`Welcome back, ${data.profile_name}!`, "success")
            // Reload dashboard after profile switch
            setTimeout(() => window.location.reload(), 1500)
          } else {
            this.updateStatus(data.error || "Face not recognized", "error")
          }
        }
      } else {
        this.updateStatus("Recognition failed. Try again.", "error")
      }
    } catch (error) {
      console.error("Recognition error:", error)
      this.updateStatus("An error occurred during recognition.", "error")
    }
  }

  retake() {
    if (this.hasPreviewTarget) {
      this.previewTarget.classList.add("hidden")
    }
    this.updateStatus("Camera active — capture a new photo", "info")
  }

  updateStatus(message, type) {
    if (this.hasStatusTarget) {
      const colors = {
        info: "text-sv-secondary",
        success: "text-sv-success",
        error: "text-sv-accent",
        warning: "text-sv-warning"
      }
      this.statusTarget.className = `text-sm mt-2 ${colors[type] || "text-sv-text-muted"}`
      this.statusTarget.textContent = message
    }
  }
}
