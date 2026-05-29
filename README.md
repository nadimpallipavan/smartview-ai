# SmartView AI — Intelligent Smart TV / IPTV-OTT Streaming Platform

A full-stack, production-ready Smart TV streaming application built entirely in **Ruby on Rails 7**.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Ruby on Rails 7.1 (full-stack monolith) |
| Frontend | Hotwire (Turbo Drive, Turbo Frames, Turbo Streams) + Stimulus |
| Styling | Tailwind CSS with custom `sv-*` design tokens |
| Database | PostgreSQL 16 |
| Background Jobs | Sidekiq + Redis |
| Auth | Devise |
| Media | Active Storage (local dev → S3 prod) |
| Video | HLS.js via Stimulus controller |
| Face Recognition | AWS Rekognition + offline mock mode |
| Recommendations | Item-based collaborative filtering (pure Ruby) |
| Containerization | Docker + docker-compose |

---

## Features

- **Multi-stream playback** — up to 5 simultaneous HLS streams in a responsive grid
- **AI Recommendations** — cosine similarity collaborative filtering, refreshed via Sidekiq
- **Profile system** — multiple per-user profiles with kids mode
- **Face recognition** — AWS Rekognition enrollment + auto profile switching (with offline mock)
- **Live TV** — channel guide with category filtering
- **Content catalog** — movies, series, documentaries with genre/type filtering
- **Admin CMS** — full CRUD for content, streams, and user management
- **Encrypted face data** — AES-256 via Active Record Encryption

---

## Quick Start

### Prerequisites

- Docker Desktop installed and running
- (Optional) AWS account for S3, CloudFront, and Rekognition

### 1. Clone & configure

```bash
git clone <repo-url>
cd Smart_view
cp .env.example .env
# Edit .env with your credentials (see Environment Variables below)
```

### 2. Start with Docker Compose

```bash
docker-compose up --build
```

This starts:
- `web` — Rails app on http://localhost:3000
- `sidekiq` — Background job worker
- `postgres` — PostgreSQL 16
- `redis` — Redis 7

### 3. Set up the database

In a separate terminal:

```bash
docker-compose exec web bundle exec rails db:create db:migrate db:seed
```

### 4. Open the app

Visit **http://localhost:3000**

**Demo credentials:**
- Admin: `admin@smartview.ai` / `password123`
- Demo User: `demo@smartview.ai` / `password123`

---

## Local Development (without Docker)

### Prerequisites

- Ruby 3.2.2 (`rbenv` or `rvm`)
- PostgreSQL 16
- Redis
- Node.js (for Tailwind CSS)

### Setup

```bash
bundle install
cp .env.example .env
# Configure DATABASE_URL and REDIS_URL in .env

bundle exec rails db:create db:migrate db:seed
bundle exec rails tailwindcss:build
```

### Run

Start Rails, Sidekiq, and Tailwind watch in separate terminals:

```bash
# Terminal 1 — Rails server
bundle exec rails s

# Terminal 2 — Sidekiq worker
bundle exec sidekiq

# Terminal 3 — Tailwind CSS watcher
bundle exec rails tailwindcss:watch
```

---

## Environment Variables

Copy `.env.example` to `.env` and configure:

```env
# Database (Docker default — change for production)
DATABASE_URL=postgres://smartview:smartview@localhost:5432/smartview_development

# Redis
REDIS_URL=redis://localhost:6379/0

# Active Record Encryption (generate unique keys for production!)
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=your-32-char-primary-key-here
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=your-32-char-det-key-here
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=your-salt-here

# AWS S3 (Active Storage — leave blank to use local disk in dev)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=us-east-1
AWS_S3_BUCKET=

# AWS CloudFront CDN (optional)
CLOUDFRONT_DOMAIN=

# AWS Rekognition (face recognition — leave blank to use mock mode)
AWS_REKOGNITION_COLLECTION_ID=smartview-faces

# Face Recognition Mode: "aws" or "mock" (default: mock in dev)
FACE_RECOGNITION_MODE=mock

# Rails
RAILS_ENV=development
SECRET_KEY_BASE=
```

### Generating Encryption Keys

```bash
# Generate a random 32-character key
ruby -e "require 'securerandom'; puts SecureRandom.hex(16)"
```

---

## Architecture

### Models

```
User                 ─── has_many :profiles
Profile              ─── belongs_to :user
                         has_one :face_embedding
                         has_many :viewing_histories
                         has_many :recommendations
Content              ─── has_many :viewing_histories
                         has_many :recommendations
Stream               ─── (standalone, Active Storage logo)
ViewingHistory       ─── profile + content + progress(float) + completed
FaceEmbedding        ─── profile + encrypted external_face_id + status
Recommendation       ─── profile + content + score + reason
```

### Face Recognition Flow

```
1. User clicks "Enroll Face" → Webcam Stimulus controller activates
2. getUserMedia captures webcam frame → canvas.toDataURL
3. Form POST to /profiles/:id/capture_face with base64 image
4. FaceRecognitionService:
   - AWS mode: index face into Rekognition collection, store encrypted face ID
   - Mock mode: store profile ID as the "face ID" (offline testing)
5. Auto-switch via Turbo Stream response (no page reload)
```

### Recommendation Engine

```
RecommendationService (pure Ruby):
1. Build user-item interaction matrix (profiles × content)
   - Value = viewing progress * (1.5 if completed)
2. Transpose to item vectors (item × users)
3. Calculate cosine similarity between all item pairs
4. Score unseen items by summing (similarity × interaction)
5. Apply 1.3× bonus for preferred genres
6. Persist top 30 to recommendations table
7. Triggered by RecommendationRefreshJob (Sidekiq, every hour)
```

### Key Stimulus Controllers

| Controller | Purpose |
|-----------|---------|
| `hls-player` | HLS.js wrapper, progress tracking, view recording |
| `webcam` | getUserMedia face capture for enrollment/recognition |
| `multiscreen` | Grid layout management for simultaneous streams |
| `search` | Real-time search input handling |
| `carousel` | Featured content carousel |
| `dropdown` | User menu and navigation dropdowns |

---

## Admin Panel

Access at `/admin` (requires admin account).

- **Contents** — Add/edit/delete movies, series, documentaries. Set featured flag, publish/draft status, upload posters and backdrops.
- **Streams** — Manage live channels. Set HLS URLs, category, live status.
- **Users** — Edit subscription tiers, max streams, admin flags.
- **Sidekiq UI** — Job queue monitor at `/sidekiq` (admin only).

---

## Production Deployment (AWS EC2)

### 1. Build production image

```bash
docker build -t smartview-ai:latest .
```

### 2. Configure environment

Set production environment variables with real AWS credentials and a generated `SECRET_KEY_BASE`:

```bash
rails secret  # generates SECRET_KEY_BASE
```

### 3. Active Storage (S3)

Update `config/storage.yml` — the Amazon S3 config is pre-wired. Set `AWS_*` env vars.

Change `config/environments/production.rb`:
```ruby
config.active_storage.service = :amazon
```

### 4. Precompile assets

```bash
bundle exec rails assets:precompile RAILS_ENV=production
```

### 5. Run migrations

```bash
bundle exec rails db:migrate RAILS_ENV=production
```

---

## Running Tests

```bash
bundle exec rspec
```

---

## API Endpoints (JSON)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/recognize_face` | Face recognition → returns profile match |
| POST | `/contents/:id/record_view` | Record viewing progress |

---

## Project Structure

```
app/
├── assets/stylesheets/application.tailwind.css  # Custom sv-* classes
├── controllers/
│   ├── application_controller.rb               # Auth, profile helpers, Pagy
│   ├── dashboard_controller.rb                 # Home page data
│   ├── contents_controller.rb                  # Catalog, search, genre
│   ├── streams_controller.rb                   # Live TV
│   ├── multiscreen_controller.rb               # Multi-stream grid
│   ├── player_controller.rb                    # Video player
│   ├── profiles_controller.rb                  # Profile CRUD + face enrollment
│   ├── face_recognition_controller.rb          # Face recognition endpoint
│   ├── recommendations_controller.rb           # AI recommendations page
│   └── admin/                                  # Admin CMS controllers
├── javascript/controllers/
│   ├── hls_player_controller.js                # HLS.js integration
│   ├── webcam_controller.js                    # Face capture
│   ├── multiscreen_controller.js               # Grid management
│   ├── search_controller.js                    # Live search
│   ├── carousel_controller.js                  # Content carousel
│   └── dropdown_controller.js                  # Menus
├── models/                                     # 7 models + ApplicationRecord
├── services/
│   ├── face_recognition_service.rb             # AWS Rekognition + mock mode
│   └── recommendation_service.rb               # Collaborative filtering
├── jobs/
│   └── recommendation_refresh_job.rb           # Sidekiq job
└── views/
    ├── layouts/                                # application, devise, admin, landing
    ├── landing/index.html.erb                  # Public landing page
    ├── dashboard/index.html.erb                # Authenticated home
    ├── profiles/                               # Profile management + face enrollment
    ├── contents/                               # Content catalog + player pages
    ├── streams/                                # Live TV channel guide
    ├── multiscreen/index.html.erb              # Simultaneous stream grid
    ├── recommendations/index.html.erb          # AI recommendations
    ├── player/show.html.erb                    # Full-screen HLS player
    ├── devise/                                 # Auth forms
    └── admin/                                  # Admin CMS views
config/
├── routes.rb                                   # All routes
├── tailwind.config.js                          # Custom color tokens
├── importmap.rb                                # JS dependencies (hls.js, hotwire)
└── storage.yml                                 # Local + S3 storage config
db/
├── migrate/                                    # 8 migration files
└── seeds.rb                                    # Demo data + credentials
```

---

## License

MIT
