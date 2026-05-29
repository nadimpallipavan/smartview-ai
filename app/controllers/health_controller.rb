# frozen_string_literal: true

class HealthController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def show
    render json: {
      status: "ok",
      version: "1.0.0",
      rails: Rails.version,
      ruby: RUBY_VERSION,
      time: Time.current.iso8601
    }
  end
end
