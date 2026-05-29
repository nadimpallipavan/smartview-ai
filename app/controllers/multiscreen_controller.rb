# frozen_string_literal: true

class MultiscreenController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_profile!

  def index
    @streams = Stream.live_now.limit(current_user.max_streams)
    @available_streams = Stream.active
    @max_streams = current_user.max_streams
    @selected_ids = params[:stream_ids]&.map(&:to_i) || @streams.pluck(:id)

    if @selected_ids.any?
      @active_streams = Stream.where(id: @selected_ids).limit(@max_streams)
    else
      @active_streams = @streams
    end
  end
end
