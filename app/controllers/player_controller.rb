# frozen_string_literal: true

class PlayerController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_profile!

  def show
    @content = Content.find(params[:id])
    @viewing_history = current_profile.viewing_histories.find_by(content: @content)
    @content.increment_views!
  end
end
