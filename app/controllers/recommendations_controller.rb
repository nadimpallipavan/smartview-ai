# frozen_string_literal: true

class RecommendationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_profile!

  def index
    @recommendations = current_profile.recommendations
                                       .includes(:content)
                                       .top(24)
    @profile = current_profile
  end
end
