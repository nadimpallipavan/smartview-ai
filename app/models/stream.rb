# frozen_string_literal: true

class Stream < ApplicationRecord
  has_one_attached :logo

  validates :name, presence: true
  validates :hls_url, presence: true

  scope :active, -> { where(is_active: true) }
  scope :live_now, -> { active.where(is_live: true) }
  scope :by_category, ->(cat) { where(category: cat) }

  CATEGORIES = %w[News Sports Entertainment Music Kids Documentary Technology Gaming].freeze

  def logo_display_url
    if logo.attached?
      logo
    else
      logo_url || "https://via.placeholder.com/100x100/1a1a28/6366f1?text=#{CGI.escape(name[0..2])}"
    end
  end

  def status_badge
    is_live ? "🔴 LIVE" : "⏸ Offline"
  end
end
