# frozen_string_literal: true

class ViewingHistory < ApplicationRecord
  belongs_to :profile
  belongs_to :content

  validates :watched_at, presence: true

  scope :recent, -> { order(watched_at: :desc) }
  scope :completed, -> { where(completed: true) }
  scope :in_progress, -> { where(completed: false).where("progress > ?", 0.0) }

  def percentage_watched
    (progress * 100).round
  end
end
