# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [:show, :edit, :update, :destroy, :switch, :enroll_face, :capture_face]

  def index
    @profiles = current_user.profiles
  end

  def show
    @viewing_history = @profile.viewing_histories.includes(:content).recent.limit(20)
  end

  def new
    @profile = current_user.profiles.build
  end

  def create
    @profile = current_user.profiles.build(profile_params)
    @profile.avatar_color = %w[#6366f1 #06b6d4 #f43f5e #10b981 #f59e0b #8b5cf6].sample

    if @profile.save
      redirect_to profiles_path, notice: "Profile created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @profile.update(profile_params)
      redirect_to profiles_path, notice: "Profile updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @profile.is_default?
      redirect_to profiles_path, alert: "Cannot delete default profile"
    else
      @profile.destroy
      redirect_to profiles_path, notice: "Profile deleted"
    end
  end

  def switch
    session[:profile_id] = @profile.id
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("profile-indicator", partial: "profiles/indicator", locals: { profile: @profile }),
          turbo_stream.replace("main-content", partial: "dashboard/content", locals: { profile: @profile })
        ]
      }
      format.html { redirect_to dashboard_path, notice: "Switched to #{@profile.name}" }
    end
  end

  def enroll_face
    @face_embedding = @profile.face_embedding || @profile.build_face_embedding
  end

  def capture_face
    if params[:face_image].present?
      result = FaceRecognitionService.new.enroll(@profile, params[:face_image])

      respond_to do |format|
        if result[:success]
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace(
              "face-enrollment-status",
              partial: "profiles/face_status",
              locals: { profile: @profile, message: "Face enrolled successfully!" }
            )
          }
          format.html { redirect_to profile_path(@profile), notice: "Face enrolled!" }
        else
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace(
              "face-enrollment-status",
              partial: "profiles/face_status",
              locals: { profile: @profile, message: "Enrollment failed: #{result[:error]}" }
            )
          }
          format.html { redirect_to enroll_face_profile_path(@profile), alert: result[:error] }
        end
      end
    else
      redirect_to enroll_face_profile_path(@profile), alert: "No image provided"
    end
  end

  private

  def set_profile
    @profile = current_user.profiles.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:name, :is_kids, :avatar)
  end
end
