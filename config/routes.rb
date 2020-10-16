Rails.application.routes.draw do
  resources :organizations do
    resources :users
    resources :projects do
      resources :jobs
    end
  end

  namespace :slack do
    resources :commands, only: [:create]
    resources :shortcuts, only: [:create]
  end

  get 'auth/login', to: 'auth#login'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'auth/slack/callback', to: 'auth#callback'
end
