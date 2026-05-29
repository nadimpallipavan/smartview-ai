# frozen_string_literal: true

class LandingController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def index
    if user_signed_in?
      redirect_to dashboard_path
    else
      @featured_contents = Content.featured.limit(5)
      render layout: "landing"
    end
  end
end
