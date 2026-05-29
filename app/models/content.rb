# frozen_string_literal: true

class Content < ApplicationRecord
  has_many :viewing_histories, dependent: :destroy
  has_many :recommendations, dependent: :destroy

  has_one_attached :poster
  has_one_attached :backdrop
  has_one_attached :video

  validates :title, presence: true
  validates :genre, presence: true
  validates :content_type, inclusion: { in: %w[movie series documentary live] }

  scope :published, -> { where(published: true) }
  scope :featured, -> { where(featured: true, published: true) }
  scope :by_genre, ->(genre) { where(genre: genre) }
  scope :by_type, ->(type) { where(content_type: type) }
  scope :popular, -> { published.order(view_count: :desc) }
  scope :recent, -> { published.order(created_at: :desc) }
  scope :top_rated, -> { published.where("rating > ?", 7.0).order(rating: :desc) }

  # Full text search
  scope :search_by_title, ->(query) {
    where("title ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
  }

  GENRES = %w[Action Comedy Drama Horror Sci-Fi Thriller Documentary Animation Romance Mystery Sports News Kids].freeze

  def formatted_duration
    return "N/A" unless duration
    hours = duration / 60
    mins = duration % 60
    hours > 0 ? "#{hours}h #{mins}m" : "#{mins}m"
  end

  def poster_url
    if poster.attached?
      poster
    else
      "https://via.placeholder.com/300x450/1a1a28/6366f1?text=#{CGI.escape(title)}"
    end
  end

  def backdrop_url
    if backdrop.attached?
      backdrop
    else
      "https://via.placeholder.com/1280x720/0a0a0f/6366f1?text=#{CGI.escape(title)}"
    end
  end

  def increment_views!
    increment!(:view_count)
  end
end
