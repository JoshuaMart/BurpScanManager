# frozen_string_literal: true

Rails.application.routes.draw do
  get 'users/index'
  devise_for :users, skip: %i[registrations passwords]

  # Defines the root path route ("/")
  root 'home#index'

  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#internal_server_error'

  resources :users
  
  resources :settings, only: [:index, :update]
  put 'settings', to: 'settings#update'

  resources :scans, only: [:new, :create]

  resources :vulnerabilities, only: [:index, :show] do
    member do
      patch :triage
    end
  end
end
