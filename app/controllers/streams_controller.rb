# frozen_string_literal: true

class StreamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_profile!

  def index
    @streams = Stream.active.order(:channel_number)
    @categories = Stream::CATEGORIES
    @streams = @streams.by_category(params[:category]) if params[:category].present?
  end

  def show
    @stream = Stream.find(params[:id])
    @related_streams = Stream.active
                             .where(category: @stream.category)
                             .where.not(id: @stream.id)
                             .limit(6)
  end
end
