# frozen_string_literal: true

class RecommendationRefreshJob < ApplicationJob
  queue_as :default

  # Refresh recommendations for a specific profile or all profiles
  def perform(profile_id = nil)
    if profile_id
      profile = Profile.find_by(id: profile_id)
      return unless profile

      Rails.logger.info("Refreshing recommendations for profile: #{profile.name}")
      RecommendationService.new(profile).generate!
    else
      Rails.logger.info("Refreshing recommendations for all profiles")
      Profile.find_each do |profile|
        RecommendationService.new(profile).generate!
      end
    end
  end
end
