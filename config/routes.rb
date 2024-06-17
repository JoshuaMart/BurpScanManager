# frozen_string_literal: true

Rails.application.routes.draw do
  get 'users/index'
  devise_for :users, skip: %i[registrations passwords]

  # Defines the root path route ("/")
  root 'home#index'

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
