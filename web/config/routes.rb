Rails.application.routes.draw do
  root :to => "pages#home"

  devise_for :users, :skip => [:registrations]

  resources :book, :only => [:show] do
    resource :entry, :only => [:create]
  end

  get "/book/:id/:requested_time", :to => "book#show", :as => :book_at
end
