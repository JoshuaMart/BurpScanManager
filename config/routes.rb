Rails.application.routes.draw do
  get 'users/index'
  devise_for :users, skip: %i[registrations passwords]

  # Defines the root path route ("/")
  root 'home#index'

  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#internal_server_error'

  resources :users
end
