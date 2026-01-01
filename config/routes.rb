Rails.application.routes.draw do
  mount_avo

  # Authentication (outside locale scope - OAuth callbacks don't need localization)
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  delete "/logout", to: "sessions#destroy"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Localized routes
  scope "(:locale)", locale: /en|zh-CN/ do
    resources :listings, only: %i[index show new create]
    get "/categories/:category", to: "listings#index", as: :category
    resources :tags, only: %i[index show], param: :slug
    resources :posts, only: %i[index show], param: :slug, path: "blog"
    root "listings#index"
  end
end
