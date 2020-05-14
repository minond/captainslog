Rails.application.routes.draw do
  root "home#home"

  devise_for :user, :only => [:sessions]

  # cancel_user_registration GET    /user/cancel(.:format)   devise/registrations#cancel
  #    new_user_registration GET    /user/sign_up(.:format)  devise/registrations#new
  #   edit_user_registration GET    /user/edit(.:format)     devise/registrations#edit
  #        user_registration PATCH  /user(.:format)          devise/registrations#update
  #                          PUT    /user(.:format)          devise/registrations#update
  #                          DELETE /user(.:format)          devise/registrations#destroy
  #                          POST   /user(.:format)          devise/registrations#create
  as :user do
    get "user/sign_up" => "devise/registrations#new", :as => :new_user_registration
    post "user" => "devise/registrations#create", :as => :user_registration
  end

  authenticated :user do
    resources :job, :only => %i[show]
    resources :connection, :only => %i[new create destroy] do
      member do
        get :authenticate
        get :schedule_pull
      end

      collection do
        namespace :initiate, :module => nil do
          get :fitbit, :action => :fitbit_initiate
          get :lastfm, :action => :lastfm_initiate
        end

        namespace :oauth, :module => nil do
          get :fitbit, :action => :fitbit_oauth
        end

        namespace :callback, :module => nil do
          get :lastfm, :action => :lastfm_callback
        end
      end
    end
  end
end
