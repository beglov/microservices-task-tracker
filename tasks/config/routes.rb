Rails.application.routes.draw do
  devise_for :accounts, controllers: {
    omniauth_callbacks: "accounts/omniauth_callbacks",
  } do
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_accounts_session
  end

  root "tasks#index"

  resources :tasks do
    post :reshuffle, on: :collection
    post :close, on: :member
  end
end
