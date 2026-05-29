import { Controller } from "@hotwired/stimulus"
import Hls from "hls.js"

// HLS Player Stimulus Controller
// Wraps the <video> element with hls.js for HLS playback
// Handles play/pause, progress tracking, and view recording
export default class extends Controller {
  static targets = ["video", "playButton", "progress", "time", "volume", "fullscreen", "overlay", "loading"]
  static values = {
    url: String,
    contentId: Number,
    startPosition: { type: Number, default: 0 }
  }

  connect() {
    this.hls = null
    this.isPlaying = false
    this.progressInterval = null
    this.initPlayer()
  }

  disconnect() {
    this.cleanup()
  }

  initPlayer() {
    const video = this.videoTarget

    if (!this.urlValue) {
      console.warn("No HLS URL provided, using demo source")
      // Use a public HLS test stream as fallback
      this.urlValue = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
    }

    if (Hls.isSupported()) {
      this.hls = new Hls({
        enableWorker: true,
        lowLatencyMode: true,
        backBufferLength: 90
      })

      this.hls.loadSource(this.urlValue)
      this.hls.attachMedia(video)

      this.hls.on(Hls.Events.MANIFEST_PARSED, () => {
        this.hideLoading()
        if (this.startPositionValue > 0) {
          video.currentTime = video.duration * this.startPositionValue
        }
      })

      this.hls.on(Hls.Events.ERROR, (event, data) => {
        if (data.fatal) {
          switch (data.type) {
            case Hls.ErrorTypes.NETWORK_ERROR:
              console.error("Network error, attempting recovery...")
              this.hls.startLoad()
              break
            case Hls.ErrorTypes.MEDIA_ERROR:
              console.error("Media error, attempting recovery...")
              this.hls.recoverMediaError()
              break
            default:
              console.error("Fatal HLS error:", data)
              this.cleanup()
              break
          }
        }
      })
    } else if (video.canPlayType("application/vnd.apple.mpegurl")) {
      // Native HLS support (Safari)
      video.src = this.urlValue
      video.addEventListener("loadedmetadata", () => {
        this.hideLoading()
      })
    }

    // Event listeners
    video.addEventListener("play", () => this.onPlay())
    video.addEventListener("pause", () => this.onPause())
    video.addEventListener("timeupdate", () => this.onTimeUpdate())
    video.addEventListener("ended", () => this.onEnded())
    video.addEventListener("waiting", () => this.showLoading())
    video.addEventListener("canplay", () => this.hideLoading())
  }

  // Actions
  togglePlay() {
    const video = this.videoTarget
    if (video.paused) {
      video.play()
    } else {
      video.pause()
    }
  }

  seek(event) {
    if (!this.hasProgressTarget) return
    const rect = this.progressTarget.getBoundingClientRect()
    const pos = (event.clientX - rect.left) / rect.width
    this.videoTarget.currentTime = pos * this.videoTarget.duration
  }

  changeVolume(event) {
    this.videoTarget.volume = event.target.value / 100
  }

  toggleMute() {
    this.videoTarget.muted = !this.videoTarget.muted
  }

  toggleFullscreen() {
    if (!document.fullscreenElement) {
      this.element.requestFullscreen()
    } else {
      document.exitFullscreen()
    }
  }

  // Callbacks
  onPlay() {
    this.isPlaying = true
    if (this.hasPlayButtonTarget) {
      this.playButtonTarget.innerHTML = `<svg class="w-8 h-8" fill="currentColor" viewBox="0 0 24 24"><path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z"/></svg>`
    }
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("opacity-0")
    }
    this.startProgressTracking()
  }

  onPause() {
    this.isPlaying = false
    if (this.hasPlayButtonTarget) {
      this.playButtonTarget.innerHTML = `<svg class="w-8 h-8" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>`
    }
    this.stopProgressTracking()
    this.recordProgress()
  }

  onTimeUpdate() {
    const video = this.videoTarget
    if (this.hasTimeTarget && video.duration) {
      const current = this.formatTime(video.currentTime)
      const duration = this.formatTime(video.duration)
      this.timeTarget.textContent = `${current} / ${duration}`
    }
    if (this.hasProgressTarget && video.duration) {
      const pct = (video.currentTime / video.duration) * 100
      this.progressTarget.style.setProperty("--progress", `${pct}%`)
    }
  }

  onEnded() {
    this.isPlaying = false
    this.recordProgress(1.0)
  }

  // Progress tracking
  startProgressTracking() {
    this.progressInterval = setInterval(() => {
      this.recordProgress()
    }, 30000) // Report every 30 seconds
  }

  stopProgressTracking() {
    if (this.progressInterval) {
      clearInterval(this.progressInterval)
      this.progressInterval = null
    }
  }

  recordProgress(forceProgress = null) {
    if (!this.contentIdValue) return

    const video = this.videoTarget
    const progress = forceProgress || (video.duration ? video.currentTime / video.duration : 0)
    const duration = Math.round(video.currentTime)

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    fetch(`/contents/${this.contentIdValue}/record_view`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({ progress: progress, duration: duration })
    }).catch(err => console.warn("Failed to record progress:", err))
  }

  // Loading states
  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove("hidden")
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add("hidden")
    }
  }

  // Utilities
  formatTime(seconds) {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    const s = Math.floor(seconds % 60)
    if (h > 0) {
      return `${h}:${m.toString().padStart(2, "0")}:${s.toString().padStart(2, "0")}`
    }
    return `${m}:${s.toString().padStart(2, "0")}`
  }

  cleanup() {
    this.stopProgressTracking()
    if (this.hls) {
      this.hls.destroy()
      this.hls = null
    }
  }
}
