Rails.application.routes.draw do
  root "dashboard#index"

  devise_for :accounts, controllers: {
    omniauth_callbacks: "accounts/omniauth_callbacks",
  } do
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_accounts_session
  end

  get "dashboard/index"
end
