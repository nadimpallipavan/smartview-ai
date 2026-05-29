# frozen_string_literal: true

module Admin
  class ContentsController < BaseController
    before_action :set_content, only: [:show, :edit, :update, :destroy]

    def index
      @contents = Content.order(created_at: :desc)
      @pagy, @contents = pagy(@contents)
    end

    def show; end

    def new
      @content = Content.new
    end

    def create
      @content = Content.new(content_params)
      if @content.save
        redirect_to admin_content_path(@content), notice: "Content created!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @content.update(content_params)
        redirect_to admin_content_path(@content), notice: "Content updated!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @content.destroy
      redirect_to admin_contents_path, notice: "Content deleted!"
    end

    private

    def set_content
      @content = Content.find(params[:id])
    end

    def content_params
      params.require(:content).permit(
        :title, :description, :genre, :content_type, :hls_url, :trailer_url,
        :duration, :rating, :year, :maturity_rating, :language, :director,
        :featured, :published, :poster, :backdrop, :video, cast: [], tags: []
      )
    end
  end
end
