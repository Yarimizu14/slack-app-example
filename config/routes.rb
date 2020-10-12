Rails.application.routes.draw do
  resources :organizations
  resources :projects do
    resources :jobs
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'auth/slack/callback', to: 'auth#callback'
end
