require "sidekiq/web"

Rails.application.routes.draw do
  # Devise authentication
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  # Sidekiq Web UI (admin only)
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  # Profile management
  resources :profiles do
    member do
      post :switch
      post :enroll_face
      post :capture_face
    end
  end

  # Face recognition endpoint
  post "/recognize_face", to: "face_recognition#recognize"

  # Content catalog
  resources :contents, only: [:index, :show] do
    member do
      post :record_view
    end
    collection do
      get :search
      get :genre
    end
  end

  # Streams (live channels)
  resources :streams, only: [:index, :show]

  # Multi-screen view
  get "/multiscreen", to: "multiscreen#index", as: :multiscreen

  # Recommendations
  get "/recommendations", to: "recommendations#index", as: :recommendations

  # Player
  get "/player/:id", to: "player#show", as: :player

  # Admin
  namespace :admin do
    resources :contents
    resources :streams
    resources :users, only: [:index, :show, :edit, :update, :destroy]
    root to: "contents#index"
  end

  # Dashboard (authenticated root)
  get "/dashboard", to: "dashboard#index", as: :dashboard

  # Health check
  get "/health", to: "health#show"

  # Root
  root "landing#index"
end
