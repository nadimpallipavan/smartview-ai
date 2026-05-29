# frozen_string_literal: true

class FaceRecognitionController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:recognize]

  def recognize
    if params[:face_image].blank?
      render json: { error: "No image provided" }, status: :bad_request
      return
    end

    service = FaceRecognitionService.new
    result = service.recognize(current_user, params[:face_image])

    if result[:success] && result[:profile]
      session[:profile_id] = result[:profile].id

      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("profile-indicator",
              partial: "profiles/indicator",
              locals: { profile: result[:profile] }),
            turbo_stream.replace("face-recognition-status",
              html: "<div id='face-recognition-status' class='text-sv-success text-sm'>✓ Welcome back, #{result[:profile].name}!</div>")
          ]
        }
        format.json { render json: { success: true, profile_id: result[:profile].id, profile_name: result[:profile].name } }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("face-recognition-status",
            html: "<div id='face-recognition-status' class='text-sv-accent text-sm'>Face not recognized</div>")
        }
        format.json { render json: { success: false, error: result[:error] || "Face not recognized" } }
      end
    end
  end
end
