Rails.application.routes.draw do
  root :to => "homepage#home"

  devise_for :users, :skip => %i[registrations sessions]
  as :user do
    post "/users/sign_in" => "devise/sessions#create", :as => :user_session
    delete "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

  resources :book, :only => %i[create new edit show update destroy], :param => :book_slug
  post "/book/:book_slug/entry", :to => "entries#create", :as => :book_entry
  get "/book/:book_slug/:requested_time", :to => "book#show", :as => :book_at

  resource :search, :only => %i[show]
  resource :user, :only => %i[show update]
  resources :entries, :only => %i[show update destroy]
  resources :extractors, :only => %i[show update]
  resources :shorthands, :only => %i[show update]
end
