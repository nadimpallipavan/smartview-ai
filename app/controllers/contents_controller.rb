# frozen_string_literal: true

class ContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_profile!
  before_action :set_content, only: [:show, :record_view]

  def index
    @contents = Content.published
    @contents = @contents.by_genre(params[:genre]) if params[:genre].present?
    @contents = @contents.by_type(params[:type]) if params[:type].present?
    @contents = @contents.order(created_at: :desc)
    @pagy, @contents = pagy(@contents)
    @genres = Content::GENRES
  end

  def show
    @related = Content.published
                      .where(genre: @content.genre)
                      .where.not(id: @content.id)
                      .limit(12)
  end

  def search
    query = params[:q].to_s.strip
    if query.present?
      @contents = Content.published.search_by_title(query)
      @pagy, @contents = pagy(@contents)
    else
      @contents = Content.none
    end

    respond_to do |format|
      format.html
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "search-results",
          partial: "contents/search_results",
          locals: { contents: @contents }
        )
      }
    end
  end

  def genre
    @genre = params[:name]
    @contents = Content.published.by_genre(@genre).order(rating: :desc)
    @pagy, @contents = pagy(@contents)
  end

  def record_view
    viewing = current_profile.viewing_histories.find_or_initialize_by(content: @content)
    viewing.assign_attributes(
      watched_at: Time.current,
      progress: params[:progress].to_f,
      watch_duration_seconds: params[:duration].to_i
    )
    viewing.completed = viewing.progress >= 0.9
    viewing.save!

    @content.increment_views!

    head :ok
  end

  private

  def set_content
    @content = Content.find(params[:id])
  end
end
