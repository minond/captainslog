Rails.application.routes.draw do
  root :to => "pages#home"

  devise_for :users, :skip => [:registrations]

  resources :book, :only => [:show] do
    get "/:requested_time", :action => :show, :as => :at
    post :entry
  end
end
