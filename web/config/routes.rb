Rails.application.routes.draw do
  root to: 'pages#home'

  devise_for :users, skip: [:registrations]

  resources :book, :only => [:show] do
    post :entry
  end
end
