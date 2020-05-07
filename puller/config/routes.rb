Rails.application.routes.draw do
  root "home#home"

  devise_for :users, :only => [:sessions]

  # cancel_user_registration GET    /users/cancel(.:format)   devise/registrations#cancel
  #    new_user_registration GET    /users/sign_up(.:format)  devise/registrations#new
  #   edit_user_registration GET    /users/edit(.:format)     devise/registrations#edit
  #        user_registration PATCH  /users(.:format)          devise/registrations#update
  #                          PUT    /users(.:format)          devise/registrations#update
  #                          DELETE /users(.:format)          devise/registrations#destroy
  #                          POST   /users(.:format)          devise/registrations#create
  as :user do
    get "users/sign_up" => "devise/registrations#new", :as => :new_user_registration
    post "users" => "devise/registrations#create", :as => :user_registration
  end

  authenticated :user do
  end
end
