Rails.application.routes.draw do
  root :to => "pages#home"

  as :user do
    post "/users/sign_in" => "devise/sessions#create", :as => :user_session
    delete "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

  resource :search, :only => [:show]

  resources :book, :only => [:show] do
    resource :entry, :only => [:create]
  end

  get "/book/:id/:requested_time", :to => "book#show", :as => :book_at
end
