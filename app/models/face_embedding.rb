# frozen_string_literal: true

class FaceEmbedding < ApplicationRecord
  belongs_to :profile

  # Encrypt sensitive face data using Active Record Encryption
  encrypts :external_face_id
  encrypts :face_data

  validates :profile_id, uniqueness: true
  validates :status, inclusion: { in: %w[pending enrolled failed] }

  scope :enrolled, -> { where(status: "enrolled") }

  def enrolled?
    status == "enrolled"
  end

  def mark_enrolled!(face_id)
    update!(
      external_face_id: face_id,
      status: "enrolled",
      enrolled_at: Time.current
    )
  end

  def mark_failed!
    update!(status: "failed")
  end
end
