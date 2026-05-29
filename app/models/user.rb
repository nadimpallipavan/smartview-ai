# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :profiles, dependent: :destroy
  has_one :active_profile, -> { where(is_default: true) }, class_name: "Profile"

  validates :name, presence: true
  validates :max_streams, numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  validates :subscription_tier, inclusion: { in: %w[free basic premium enterprise] }

  after_create :create_default_profile

  def admin?
    admin
  end

  def current_profile
    # Return session-stored profile or default
    active_profile || profiles.first
  end

  def can_add_stream?
    # Check if user hasn't exceeded max simultaneous streams
    true # Simplified for demo
  end

  private

  def create_default_profile
    profiles.create!(
      name: name,
      is_default: true,
      avatar_color: %w[#6366f1 #06b6d4 #f43f5e #10b981 #f59e0b #8b5cf6].sample
    )
  end
end
