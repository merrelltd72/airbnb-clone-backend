Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  # User routes
  post "/users" => "user#create"

  # User login route
  post "sessions" => "sessions#create"

  # User logout route
  delete "/sessions" => "sessions#destroy"

  # CRUD routes for Rooms
  get "/rooms" => "rooms#index"
  post "/rooms" => "rooms#create"
  get "/rooms/:id" => "rooms#show"
  patch "/rooms/:id" => "rooms#update"
  delete "/rooms/:id" => "rooms#destroy"
end
