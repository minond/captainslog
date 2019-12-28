Rails.application.routes.draw do
  root :to => "pages#home"

  devise_for :users, :skip => %i[registrations sessions]
  as :user do
    post "/users/sign_in" => "devise/sessions#create", :as => :user_session
    delete "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

  get "/book/:id/:requested_time", :to => "book#show", :as => :book_at
  resources :book, :only => %i[show] do
    resource :entry, :only => %i[create]
  end

  resource :search, :only => %i[show]
  resources :user, :only => %i[show update]
end
