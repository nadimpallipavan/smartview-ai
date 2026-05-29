FROM ruby:3.2.2-slim-bookworm

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    libvips \
    imagemagick \
    node-gyp \
    pkg-config \
    python3 \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set working directory
WORKDIR /rails

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'false' && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache

# Copy application
COPY . .

# Ensure runtime directories exist (these are gitignored, so not in the repo).
# Puma needs tmp/pids for its pidfile; the rest are used at runtime.
RUN mkdir -p tmp/pids tmp/cache log storage

# Precompile bootsnap
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Precompile assets for production (Tailwind + Sprockets).
# SECRET_KEY_BASE_DUMMY lets Rails boot without a real secret during build.
# In dev (docker-compose), the bind mount hides public/assets and the web
# command rebuilds Tailwind at startup, so this only matters for production.
RUN SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bundle exec rails assets:precompile

# Entrypoint
COPY bin/docker-entrypoint /rails/bin/docker-entrypoint
RUN chmod +x /rails/bin/docker-entrypoint

EXPOSE 3000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
