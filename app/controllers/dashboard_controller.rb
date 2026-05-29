# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_profile!

  def index
    @profile = current_profile
    @featured = Content.featured.limit(6)
    @continue_watching = @profile.viewing_histories
                                  .in_progress
                                  .includes(:content)
                                  .recent
                                  .limit(10)
    @trending = Content.popular.limit(12)
    @recommendations = @profile.recommendations
                               .includes(:content)
                               .top(12)
    @live_streams = Stream.live_now.limit(6)
    @genres = Content::GENRES
    @genre_rows = {}
    @genres.first(6).each do |genre|
      contents = Content.published.by_genre(genre).limit(12)
      @genre_rows[genre] = contents if contents.any?
    end
  end
end
