# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def page_title(title = nil)
    base = "SmartView AI"
    title.present? ? "#{title} — #{base}" : base
  end

  def active_nav_class(path)
    current_page?(path) ? "bg-sv-primary/20 text-sv-primary-light border-sv-primary" : "text-sv-text-muted hover:text-sv-text hover:bg-sv-card-hover border-transparent"
  end

  def genre_icon(genre)
    icons = {
      "Action" => "🎬", "Comedy" => "😂", "Drama" => "🎭",
      "Horror" => "👻", "Sci-Fi" => "🚀", "Thriller" => "🔥",
      "Documentary" => "📹", "Animation" => "✨", "Romance" => "💕",
      "Mystery" => "🔍", "Sports" => "⚽", "News" => "📰", "Kids" => "🧸"
    }
    icons[genre] || "🎬"
  end

  def rating_stars(rating)
    full = (rating / 2.0).floor
    half = ((rating / 2.0) - full >= 0.5) ? 1 : 0
    empty = 5 - full - half

    ("★" * full) + ("½" * half) + ("☆" * empty)
  end

  def time_ago_short(time)
    return "N/A" unless time
    distance = Time.current - time
    case distance
    when 0..59 then "just now"
    when 60..3599 then "#{(distance / 60).to_i}m ago"
    when 3600..86399 then "#{(distance / 3600).to_i}h ago"
    else "#{(distance / 86400).to_i}d ago"
    end
  end
end
