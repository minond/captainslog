Rails.application.routes.draw do
  root :to => "pages#home"

  devise_for :users, :skip => %i[registrations sessions]
  as :user do
    post "/users/sign_in" => "devise/sessions#create", :as => :user_session
    delete "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

  post "/book/:book_slug/entry", :to => "entries#create", :as => :book_entry
  get "/book/:book_slug/:requested_time", :to => "book#show", :as => :book_at
  resources :book, :only => %i[show], :param => :book_slug
  resources :entry, :only => %i[destroy]

  resource :search, :only => %i[show]
  resource :user, :only => %i[show update]
end
