Rails.application.routes.draw do
  root "static_pages#home"
  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
  get "/contact", to: "static_pages#contact"
  get "/signup", to: "users#new"
  post "/signup",  to: "users#create"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  get "/microposts", to: "static_pages#home"
  get "/social_groups/:id/microposts", to: "social_groups#show"
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: :edit
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :social_groups, only: [:index, :new, :create, :show] do
    resources :group_users, only: [:create, :destroy]
    resources :microposts, only: [:create, :destroy]
  end
  resources :microposts, only: [:create, :destroy]
  resources :relationships, only: [:new, :edit, :create, :destroy]
end
