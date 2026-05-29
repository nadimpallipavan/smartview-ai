# frozen_string_literal: true

# RecommendationService implements item-based collaborative filtering
# using cosine similarity over a user-item interaction matrix.
#
# Architecture Decision: Pure Ruby implementation using the `matrix` stdlib
# instead of external ML services. This keeps the app self-contained while
# providing meaningful recommendations based on viewing patterns.
#
class RecommendationService
  require "matrix"

  def initialize(profile)
    @profile = profile
  end

  # Generate and persist recommendations for the profile
  def generate!
    return if Content.published.count < 2

    # Build interaction matrix
    profiles = Profile.includes(:viewing_histories).where.not(id: nil)
    contents = Content.published.pluck(:id)

    return if profiles.empty? || contents.empty?

    content_index = {}
    contents.each_with_index { |cid, i| content_index[cid] = i }

    # Build user-item matrix (profiles x contents)
    # Values: watch progress (0.0 - 1.0) weighted by completion
    interaction_matrix = build_interaction_matrix(profiles, content_index, contents.size)

    # Calculate item-item similarity using cosine similarity
    similarity_matrix = calculate_similarity_matrix(interaction_matrix, contents.size)

    # Generate recommendations for the target profile
    profile_vector = build_profile_vector(@profile, content_index, contents.size)

    # Score each unseen content
    scored_items = score_items(profile_vector, similarity_matrix, content_index, contents)

    # Persist top recommendations
    persist_recommendations!(scored_items)
  end

  private

  def build_interaction_matrix(profiles, content_index, num_contents)
    matrix = []

    profiles.find_each do |profile|
      row = Array.new(num_contents, 0.0)
      profile.viewing_histories.each do |vh|
        idx = content_index[vh.content_id]
        next unless idx
        # Weight: progress * (completed bonus)
        weight = vh.progress
        weight *= 1.5 if vh.completed
        row[idx] = [weight, 1.0].min
      end
      matrix << row
    end

    matrix
  end

  def build_profile_vector(profile, content_index, num_contents)
    vector = Array.new(num_contents, 0.0)
    profile.viewing_histories.each do |vh|
      idx = content_index[vh.content_id]
      next unless idx
      weight = vh.progress
      weight *= 1.5 if vh.completed
      vector[idx] = [weight, 1.0].min
    end
    vector
  end

  def calculate_similarity_matrix(interaction_matrix, num_contents)
    return Array.new(num_contents) { Array.new(num_contents, 0.0) } if interaction_matrix.empty?

    # Transpose to get item vectors (each column = one item's ratings across all users)
    item_vectors = Array.new(num_contents) { Array.new(interaction_matrix.size, 0.0) }

    interaction_matrix.each_with_index do |row, user_idx|
      row.each_with_index do |val, item_idx|
        item_vectors[item_idx][user_idx] = val
      end
    end

    # Calculate cosine similarity between all item pairs
    similarity = Array.new(num_contents) { Array.new(num_contents, 0.0) }

    num_contents.times do |i|
      (i + 1...num_contents).each do |j|
        sim = cosine_similarity(item_vectors[i], item_vectors[j])
        similarity[i][j] = sim
        similarity[j][i] = sim
      end
      similarity[i][i] = 1.0
    end

    similarity
  end

  def cosine_similarity(vec_a, vec_b)
    dot = 0.0
    norm_a = 0.0
    norm_b = 0.0

    vec_a.zip(vec_b).each do |a, b|
      dot += a * b
      norm_a += a * a
      norm_b += b * b
    end

    denominator = Math.sqrt(norm_a) * Math.sqrt(norm_b)
    return 0.0 if denominator.zero?

    dot / denominator
  end

  def score_items(profile_vector, similarity_matrix, content_index, all_content_ids)
    watched_ids = @profile.viewing_histories.pluck(:content_id).to_set
    scored = []

    all_content_ids.each do |content_id|
      next if watched_ids.include?(content_id)

      idx = content_index[content_id]
      next unless idx

      # Score = sum of (similarity to watched items * interaction strength)
      score = 0.0
      reason_items = []

      profile_vector.each_with_index do |interaction, watched_idx|
        next if interaction.zero?
        sim = similarity_matrix[idx][watched_idx]
        if sim > 0.1
          score += sim * interaction
          reason_items << watched_idx
        end
      end

      # Add genre bonus for content matching preferred genres
      content = Content.find_by(id: content_id)
      if content
        preferred_genres = @profile.viewing_histories
                                    .joins(:content)
                                    .group("contents.genre")
                                    .count
                                    .sort_by { |_, v| -v }
                                    .first(3)
                                    .map(&:first)

        score *= 1.3 if preferred_genres.include?(content.genre)
      end

      scored << { content_id: content_id, score: score.round(4), reason: generate_reason(score) } if score > 0
    end

    scored.sort_by { |s| -s[:score] }.first(30)
  end

  def generate_reason(score)
    case score
    when 0.8.. then "Highly recommended based on your viewing history"
    when 0.5...0.8 then "Similar to titles you've enjoyed"
    when 0.3...0.5 then "You might like this"
    else "Trending in your favorite genres"
    end
  end

  def persist_recommendations!(scored_items)
    Recommendation.where(profile: @profile).delete_all

    scored_items.each do |item|
      Recommendation.create!(
        profile: @profile,
        content_id: item[:content_id],
        score: item[:score],
        reason: item[:reason]
      )
    end
  end
end
