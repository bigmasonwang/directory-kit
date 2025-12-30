Rails.application.routes.draw do
  mount_avo

  # Authentication
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  delete "/logout", to: "sessions#destroy"

  # Listings
  resources :listings, only: %i[index show new create]
  get "/categories/:category", to: "listings#index", as: :category

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Homepage is listings index
  root "listings#index"
end
