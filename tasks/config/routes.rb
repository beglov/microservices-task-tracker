Rails.application.routes.draw do
  devise_for :accounts
  root "tasks#index"
  resources :tasks
end
