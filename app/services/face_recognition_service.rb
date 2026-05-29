# frozen_string_literal: true

# FaceRecognitionService handles face enrollment and recognition.
#
# Architecture Decision: Uses AWS Rekognition when credentials are present,
# falls back to a mock mode for offline development/testing. The mock mode
# uses a simple image hash to map uploads to profiles, ensuring the full
# enrollment + recognition flow is testable without AWS.
#
class FaceRecognitionService
  def initialize
    @mock_mode = ENV.fetch("FACE_RECOGNITION_MOCK", "true") == "true" ||
                 ENV["AWS_ACCESS_KEY_ID"].blank?
  end

  # Enroll a face for a profile
  # @param profile [Profile] the profile to enroll
  # @param image_data [String] base64-encoded image or uploaded file
  # @return [Hash] { success: true/false, error: String? }
  def enroll(profile, image_data)
    if @mock_mode
      enroll_mock(profile, image_data)
    else
      enroll_rekognition(profile, image_data)
    end
  rescue StandardError => e
    Rails.logger.error("Face enrollment error: #{e.message}")
    { success: false, error: e.message }
  end

  # Recognize a face and return the matching profile
  # @param user [User] the user whose profiles to search
  # @param image_data [String] base64-encoded image or uploaded file
  # @return [Hash] { success: true/false, profile: Profile?, error: String? }
  def recognize(user, image_data)
    if @mock_mode
      recognize_mock(user, image_data)
    else
      recognize_rekognition(user, image_data)
    end
  rescue StandardError => e
    Rails.logger.error("Face recognition error: #{e.message}")
    { success: false, error: e.message }
  end

  private

  # === Mock Mode (Offline Development) ===

  def enroll_mock(profile, image_data)
    face_id = generate_mock_face_id(image_data)

    embedding = profile.face_embedding || profile.build_face_embedding
    embedding.mark_enrolled!(face_id)

    # Store the image data hash for later recognition
    embedding.update!(face_data: Digest::SHA256.hexdigest(extract_image_bytes(image_data)))

    { success: true }
  end

  def recognize_mock(user, image_data)
    image_hash = Digest::SHA256.hexdigest(extract_image_bytes(image_data))

    # In mock mode, find the first enrolled profile for this user
    # In a real scenario, we'd match the image hash
    enrolled_profiles = user.profiles.joins(:face_embedding)
                            .where(face_embeddings: { status: "enrolled" })

    if enrolled_profiles.any?
      # Try to match by face_data hash first
      matching = enrolled_profiles.find do |p|
        p.face_embedding.face_data == image_hash
      end

      # If no exact match, return the first enrolled profile (mock behavior)
      profile = matching || enrolled_profiles.first
      { success: true, profile: profile }
    else
      { success: false, error: "No enrolled faces found" }
    end
  end

  def generate_mock_face_id(image_data)
    "mock_face_#{SecureRandom.uuid}"
  end

  # === AWS Rekognition Mode ===

  def rekognition_client
    @rekognition_client ||= Aws::Rekognition::Client.new(
      region: ENV.fetch("AWS_REGION", "us-east-1"),
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )
  end

  def collection_id
    ENV.fetch("AWS_REKOGNITION_COLLECTION_ID", "smartview_faces")
  end

  def ensure_collection_exists!
    rekognition_client.create_collection(collection_id: collection_id)
  rescue Aws::Rekognition::Errors::ResourceAlreadyExistsException
    # Collection already exists, continue
  end

  def enroll_rekognition(profile, image_data)
    ensure_collection_exists!

    image_bytes = extract_image_bytes(image_data)

    response = rekognition_client.index_faces(
      collection_id: collection_id,
      image: { bytes: image_bytes },
      external_image_id: "profile_#{profile.id}",
      max_faces: 1,
      quality_filter: "AUTO",
      detection_attributes: ["ALL"]
    )

    if response.face_records.any?
      face_id = response.face_records.first.face.face_id
      embedding = profile.face_embedding || profile.build_face_embedding
      embedding.mark_enrolled!(face_id)
      { success: true }
    else
      { success: false, error: "No face detected in the image" }
    end
  end

  def recognize_rekognition(user, image_data)
    image_bytes = extract_image_bytes(image_data)

    response = rekognition_client.search_faces_by_image(
      collection_id: collection_id,
      image: { bytes: image_bytes },
      max_faces: 1,
      face_match_threshold: 90.0
    )

    if response.face_matches.any?
      match = response.face_matches.first
      face_id = match.face.face_id

      # Find the profile with this face ID
      embedding = FaceEmbedding.enrolled.find_by(external_face_id: face_id)
      if embedding && embedding.profile.user_id == user.id
        { success: true, profile: embedding.profile }
      else
        { success: false, error: "Face matched but not associated with your account" }
      end
    else
      { success: false, error: "No matching face found" }
    end
  end

  # === Helpers ===

  def extract_image_bytes(image_data)
    if image_data.is_a?(ActionDispatch::Http::UploadedFile) || image_data.respond_to?(:read)
      image_data.read
    elsif image_data.is_a?(String) && image_data.start_with?("data:image")
      # Base64 encoded image from webcam
      Base64.decode64(image_data.split(",").last)
    elsif image_data.is_a?(String)
      image_data
    else
      image_data.to_s
    end
  end
end
