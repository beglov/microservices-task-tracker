Rails.application.routes.draw do
  root "tasks#index"

  devise_for :accounts, controllers: {
    omniauth_callbacks: "accounts/omniauth_callbacks",
  } do
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_accounts_session
  end

  resources :tasks do
    post :reshuffle, on: :collection
    post :close, on: :member
  end
end
