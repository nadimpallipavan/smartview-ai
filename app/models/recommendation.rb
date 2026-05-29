# frozen_string_literal: true

class Recommendation < ApplicationRecord
  belongs_to :profile
  belongs_to :content

  validates :profile_id, uniqueness: { scope: :content_id }

  scope :top, ->(limit = 20) { order(score: :desc).limit(limit) }
  scope :for_profile, ->(profile) { where(profile: profile).top }
end
