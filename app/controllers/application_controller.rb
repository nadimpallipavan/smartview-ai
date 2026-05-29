# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :authenticate_user!, except: [:index], if: :devise_controller?
  helper_method :current_profile

  protected

  def current_profile
    return nil unless current_user

    if session[:profile_id]
      current_user.profiles.find_by(id: session[:profile_id]) || current_user.current_profile
    else
      current_user.current_profile
    end
  end

  def set_current_profile!
    redirect_to profiles_path, alert: "Please select a profile" unless current_profile
  end

  def require_admin!
    redirect_to root_path, alert: "Access denied" unless current_user&.admin?
  end

  def after_sign_in_path_for(_resource)
    dashboard_path
  end

  def after_sign_out_path_for(_resource)
    root_path
  end
end
