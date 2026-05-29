# frozen_string_literal: true

module Admin
  class StreamsController < BaseController
    before_action :set_stream, only: [:show, :edit, :update, :destroy]

    def index
      @streams = Stream.order(:channel_number)
    end

    def show; end

    def new
      @stream = Stream.new
    end

    def create
      @stream = Stream.new(stream_params)
      if @stream.save
        redirect_to admin_stream_path(@stream), notice: "Stream created!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @stream.update(stream_params)
        redirect_to admin_stream_path(@stream), notice: "Stream updated!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @stream.destroy
      redirect_to admin_streams_path, notice: "Stream deleted!"
    end

    private

    def set_stream
      @stream = Stream.find(params[:id])
    end

    def stream_params
      params.require(:stream).permit(
        :name, :description, :hls_url, :category, :channel_number,
        :is_live, :is_active, :logo_url, :logo
      )
    end
  end
end
