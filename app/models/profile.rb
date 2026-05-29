# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user
  has_many :viewing_histories, dependent: :destroy
  has_many :watched_contents, through: :viewing_histories, source: :content
  has_one :face_embedding, dependent: :destroy
  has_many :recommendations, dependent: :destroy
  has_many :recommended_contents, through: :recommendations, source: :content

  has_one_attached :avatar

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id }

  scope :kids, -> { where(is_kids: true) }
  scope :adults, -> { where(is_kids: false) }

  def initials
    name.split.map(&:first).join.upcase[0..1]
  end

  def has_face_enrolled?
    face_embedding.present? && face_embedding.status == "enrolled"
  end

  def avatar_gradient
    colors = {
      "#6366f1" => "from-indigo-500 to-purple-600",
      "#06b6d4" => "from-cyan-500 to-blue-600",
      "#f43f5e" => "from-rose-500 to-pink-600",
      "#10b981" => "from-emerald-500 to-teal-600",
      "#f59e0b" => "from-amber-500 to-orange-600",
      "#8b5cf6" => "from-violet-500 to-purple-600"
    }
    colors[avatar_color] || "from-indigo-500 to-purple-600"
  end
end
