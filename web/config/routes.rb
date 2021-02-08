Rails.application.routes.draw do
  root :to => "homepage#home"

  devise_for :users,
             :only => [:sessions],
             :controllers => { :sessions => "users/sessions" }

  as :user do
    get "sign_up" => "devise/registrations#new", :as => :new_user_registration
    post "user" => "devise/registrations#create", :as => :user_registration
  end

  authenticate :user do
    resources :book, :only => %i[create new edit show update destroy], :param => :book_slug do
      resources :entry, :only => %i[create show update destroy]
      resources :extractor, :only => %i[create new show update destroy]
      resources :shorthand, :only => %i[create new show update destroy]
      get "/at/:requested_time", :to => "book#show", :as => :at
    end

    resource :search, :only => %i[show]
    resource :user, :only => %i[show update]

    resources :report, :only => %i[new edit show update create destroy] do
      resources :report_variable, :only => %i[new edit update create destroy]
      resources :report_output, :only => %i[new edit update create destroy]
    end

    post "/query/execute", :to => "query#execute"
  end

  namespace :api do
    namespace :v1 do
      resources :token, :only => %i[create]
      resources :books, :only => %i[index] do
        resources :entries, :only => %i[create]
      end
    end
  end
end
