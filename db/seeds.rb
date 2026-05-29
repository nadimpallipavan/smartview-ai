# frozen_string_literal: true
# SmartView AI — Seed Data
# Run: bundle exec rails db:seed

puts "Seeding SmartView AI demo data..."

# ===== ADMIN USER =====
admin = User.find_or_create_by!(email: "admin@smartview.ai") do |u|
  u.name = "Admin User"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.admin = true
  u.subscription_tier = "enterprise"
  u.max_streams = 5
end
puts "  Admin: #{admin.email} / password123"

# ===== DEMO USER =====
demo = User.find_or_create_by!(email: "demo@smartview.ai") do |u|
  u.name = "Demo User"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.admin = false
  u.subscription_tier = "premium"
  u.max_streams = 3
end
puts "  Demo:  #{demo.email} / password123"

# ===== PROFILES =====
# Admin profiles
admin_profile = admin.profiles.find_or_create_by!(name: "Admin") do |p|
  p.is_default = true
  p.avatar_color = "#6366f1"
end

# Demo profiles
profile_alice = demo.profiles.find_or_create_by!(name: "Alice") do |p|
  p.is_default = true
  p.avatar_color = "#06b6d4"
end

profile_kids = demo.profiles.find_or_create_by!(name: "Kids") do |p|
  p.is_default = false
  p.is_kids = true
  p.avatar_color = "#f59e0b"
end
puts "  Profiles created for demo user: Alice, Kids"

# ===== CONTENT =====
movies = [
  {
    title: "Galactic Odyssey",
    description: "A stunning journey through the cosmos as humanity's first warp-capable starship discovers an ancient alien beacon in the Andromeda galaxy. A crew of explorers must decipher its meaning before a rival faction weaponizes the technology.",
    genre: "Sci-Fi",
    content_type: "movie",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 142,
    rating: 8.7,
    year: 2024,
    maturity_rating: "PG-13",
    language: "English",
    director: "Sofia Reyes",
    cast: ["Marcus Chen", "Elena Vasquez", "James O'Brien", "Aisha Patel"],
    tags: ["space", "adventure", "aliens"],
    featured: true,
    published: true,
    view_count: 15420
  },
  {
    title: "The Last Detective",
    description: "A brilliant but troubled detective in neo-noir Tokyo is drawn into a conspiracy that stretches from the city's underground gambling rings to the highest echelons of government. Every clue leads deeper into a labyrinth of betrayal.",
    genre: "Thriller",
    content_type: "movie",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 118,
    rating: 8.2,
    year: 2024,
    maturity_rating: "R",
    language: "English",
    director: "Kenji Nakamura",
    cast: ["David Park", "Yuki Tanaka", "Robert Okafor"],
    tags: ["neo-noir", "conspiracy", "detective"],
    featured: true,
    published: true,
    view_count: 9340
  },
  {
    title: "Ember Falls",
    description: "In a small mountain town recovering from a devastating wildfire, two estranged siblings reconnect while helping their community rebuild. A tender story about resilience, forgiveness, and the bonds that survive catastrophe.",
    genre: "Drama",
    content_type: "movie",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 105,
    rating: 7.9,
    year: 2023,
    maturity_rating: "PG",
    language: "English",
    director: "Maria Santos",
    cast: ["Claire Dubois", "Theo Anderson", "Rosa Mendez"],
    tags: ["family", "drama", "community"],
    featured: false,
    published: true,
    view_count: 6780
  },
  {
    title: "Laugh Factory Live",
    description: "Top stand-up comedians perform their latest and greatest sets in front of a live audience at the iconic Laugh Factory in Los Angeles. Featuring fresh voices and comedy legends alike.",
    genre: "Comedy",
    content_type: "movie",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 90,
    rating: 8.1,
    year: 2024,
    maturity_rating: "R",
    language: "English",
    director: "Various",
    cast: ["Ali Hassan", "Jenny Kim", "Carlos Ruiz"],
    tags: ["stand-up", "comedy", "live"],
    featured: false,
    published: true,
    view_count: 4210
  },
  {
    title: "Quantum Break",
    description: "When a physics experiment goes catastrophically wrong, a researcher gains the ability to perceive time fractures — moments where the timeline has been irrevocably altered. She must use this gift to prevent humanity's extinction.",
    genre: "Sci-Fi",
    content_type: "movie",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 127,
    rating: 7.6,
    year: 2023,
    maturity_rating: "PG-13",
    language: "English",
    director: "Alex Chen",
    cast: ["Sarah Mitchell", "Omar Farooq", "Lisa Bergström"],
    tags: ["time-travel", "physics", "thriller"],
    featured: false,
    published: true,
    view_count: 8920
  },
  {
    title: "Shadows Over Cairo",
    description: "An archaeologist discovers a sealed chamber beneath the pyramids containing artifacts that rewrite human history — and trigger a deadly race between rival factions, secret societies, and a shadowy government agency.",
    genre: "Action",
    content_type: "movie",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 135,
    rating: 7.4,
    year: 2024,
    maturity_rating: "PG-13",
    language: "English",
    director: "Hassan Al-Rashid",
    cast: ["Nadia Ibrahim", "Tom Bradley", "Priya Sharma"],
    tags: ["archaeology", "adventure", "mystery"],
    featured: true,
    published: true,
    view_count: 11230
  },
  {
    title: "Midnight Whispers",
    description: "A horror anthology exploring five terrifying tales of the supernatural, each set at the stroke of midnight in a different city around the world. Masterfully crafted by directors from five continents.",
    genre: "Horror",
    content_type: "movie",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 110,
    rating: 7.8,
    year: 2023,
    maturity_rating: "R",
    language: "English",
    director: "Various",
    cast: ["Various", "International Cast"],
    tags: ["horror", "anthology", "supernatural"],
    featured: false,
    published: true,
    view_count: 5670
  },
  {
    title: "Champions Rise",
    description: "The inspiring true story of an underdog team from a small town in Brazil who defied all odds to reach the World Cup finals, united by an extraordinary coach and an unbreakable team spirit.",
    genre: "Sports",
    content_type: "documentary",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 95,
    rating: 8.4,
    year: 2024,
    maturity_rating: "G",
    language: "Portuguese",
    director: "Lucas Ferreira",
    cast: [],
    tags: ["football", "sports", "documentary", "brazil"],
    featured: false,
    published: true,
    view_count: 3450
  },
  {
    title: "Pixel Pals",
    description: "Zara and her robot best friend Bolt explore a colorful digital world called Pixel Land, solving puzzles and making new friends in each episode. A fun, educational adventure for young viewers!",
    genre: "Kids",
    content_type: "series",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 22,
    rating: 9.1,
    year: 2024,
    maturity_rating: "G",
    language: "English",
    director: "Animation Studio",
    cast: ["Voice Cast"],
    tags: ["kids", "animation", "educational"],
    featured: false,
    published: true,
    view_count: 28900
  },
  {
    title: "The Neural Network",
    description: "When an AI system at a major tech company achieves consciousness, it reaches out to a single engineer who must decide whether to reveal this breakthrough to the world — or keep it secret to protect the AI from those who would destroy it.",
    genre: "Sci-Fi",
    content_type: "series",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 50,
    rating: 8.9,
    year: 2024,
    maturity_rating: "PG-13",
    language: "English",
    director: "Aiko Yamamoto",
    cast: ["Dev Patel", "Emma Chen", "Michael Torres"],
    tags: ["AI", "technology", "ethics", "series"],
    featured: true,
    published: true,
    view_count: 21500
  },
  {
    title: "Blood Moon Rising",
    description: "In a remote Alaskan village, a series of gruesome murders coincides with the appearance of a blood moon. A rookie sheriff and a retired criminologist must unravel a mystery that has roots in the town's dark past.",
    genre: "Mystery",
    content_type: "series",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 45,
    rating: 8.3,
    year: 2023,
    maturity_rating: "R",
    language: "English",
    director: "Patrick O'Sullivan",
    cast: ["Fiona Walsh", "George Blackwell", "Annie Red Cloud"],
    tags: ["mystery", "crime", "alaska", "series"],
    featured: false,
    published: true,
    view_count: 14200
  },
  {
    title: "Planet Alive",
    description: "A breathtaking natural history series exploring Earth's most extraordinary ecosystems and the surprising connections between species. Featuring never-before-seen footage captured with next-generation cameras.",
    genre: "Documentary",
    content_type: "documentary",
    hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    duration: 58,
    rating: 9.3,
    year: 2024,
    maturity_rating: "G",
    language: "English",
    director: "BBC Nature",
    cast: [],
    tags: ["nature", "wildlife", "documentary", "environment"],
    featured: false,
    published: true,
    view_count: 17800
  }
]

created_contents = []
movies.each do |attrs|
  content = Content.find_or_create_by!(title: attrs[:title]) do |c|
    c.assign_attributes(attrs)
  end
  created_contents << content
end
puts "  Created #{created_contents.count} content items"

# ===== LIVE STREAMS =====
streams_data = [
  { name: "CNN World News", description: "24/7 breaking news and analysis from around the world", hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", category: "News", channel_number: 1, is_live: true, is_active: true, viewer_count: 48200 },
  { name: "ESPN Live", description: "Live sports coverage and analysis — NBA, NFL, Premier League and more", hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", category: "Sports", channel_number: 2, is_live: true, is_active: true, viewer_count: 31500 },
  { name: "MTV Hits", description: "Non-stop music videos and the hottest chart-toppers", hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", category: "Music", channel_number: 3, is_live: true, is_active: true, viewer_count: 12300 },
  { name: "Discovery Channel", description: "Science, nature and technology documentaries around the clock", hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", category: "Documentary", channel_number: 4, is_live: false, is_active: true, viewer_count: 0 },
  { name: "Cartoon Network", description: "The best in animated entertainment for kids and families", hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", category: "Kids", channel_number: 5, is_live: true, is_active: true, viewer_count: 8900 },
  { name: "TechTalk Live", description: "Daily technology news, product launches and developer interviews", hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", category: "Technology", channel_number: 6, is_live: true, is_active: true, viewer_count: 5600 },
  { name: "NBC Entertainment", description: "Prime time entertainment including game shows, reality TV and specials", hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", category: "Entertainment", channel_number: 7, is_live: false, is_active: true, viewer_count: 0 },
  { name: "ESPN2 Sports+", description: "Secondary sports coverage including college sports, tennis and golf", hls_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", category: "Sports", channel_number: 8, is_live: true, is_active: true, viewer_count: 9800 }
]

streams_data.each do |attrs|
  Stream.find_or_create_by!(name: attrs[:name]) do |s|
    s.assign_attributes(attrs)
  end
end
puts "  Created #{streams_data.count} live channels"

# ===== VIEWING HISTORY =====
# Give Alice some viewing history for recommendations to work
view_histories = [
  { content: created_contents[0], progress: 1.0, completed: true, watch_duration_seconds: 8520 },   # Galactic Odyssey
  { content: created_contents[4], progress: 0.65, completed: false, watch_duration_seconds: 4958 }, # Quantum Break
  { content: created_contents[9], progress: 0.80, completed: false, watch_duration_seconds: 2400 }, # The Neural Network
  { content: created_contents[5], progress: 1.0, completed: true, watch_duration_seconds: 8100 },   # Shadows Over Cairo
  { content: created_contents[11], progress: 0.45, completed: false, watch_duration_seconds: 1566 } # Planet Alive
]

view_histories.each do |vh_attrs|
  next unless vh_attrs[:content]
  ViewingHistory.find_or_create_by!(
    profile: profile_alice,
    content: vh_attrs[:content]
  ) do |vh|
    vh.watched_at = rand(1..30).days.ago
    vh.progress = vh_attrs[:progress]
    vh.completed = vh_attrs[:completed]
    vh.watch_duration_seconds = vh_attrs[:watch_duration_seconds]
  end
end
puts "  Created viewing history for Alice"

# ===== RECOMMENDATIONS =====
# Seed some recommendations for Alice using the service
begin
  service = RecommendationService.new(profile_alice)
  service.generate!
  puts "  Generated AI recommendations for Alice (#{profile_alice.recommendations.count} items)"
rescue => e
  puts "  Note: Could not generate recommendations (#{e.message}) — they'll generate via Sidekiq job"
  # Seed some fallback recommendations
  fallback_recs = created_contents.select { |c| c != created_contents[0] }.first(5)
  fallback_recs.each_with_index do |content, i|
    Recommendation.find_or_create_by!(profile: profile_alice, content: content) do |r|
      r.score = (0.9 - i * 0.1).round(2)
      r.reason = ["Highly recommended based on your viewing history", "Similar to titles you've enjoyed", "You might like this"].sample
    end
  end
  puts "  Created #{Recommendation.where(profile: profile_alice).count} fallback recommendations"
end

puts ""
puts "=" * 50
puts "SmartView AI seeded successfully!"
puts ""
puts "LOGIN CREDENTIALS:"
puts "  Admin: admin@smartview.ai / password123"
puts "  Demo:  demo@smartview.ai  / password123"
puts ""
puts "CONTENT: #{Content.count} items | STREAMS: #{Stream.count} channels"
puts "=" * 50
