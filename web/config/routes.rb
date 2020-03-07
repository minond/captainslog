# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  root :to => "homepage#home"

  devise_for :users, :skip => %i[registrations sessions]
  as :user do
    post "/users/sign_in" => "devise/sessions#create", :as => :user_session
    delete "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

  authenticate :user do
    resources :book, :only => %i[create new edit show update destroy], :param => :book_slug do
      resources :entry, :only => %i[create show update destroy]
      resources :extractor, :only => %i[create new show update destroy]
      resources :shorthand, :only => %i[create new show update destroy]
      get "/at/:requested_time", :to => "book#show", :as => :at
    end

    resources :job, :only => %i[show]
    resource :search, :only => %i[show]
    resource :user, :only => %i[show update]

    resources :report, :only => %i[new edit show update create destroy] do
      resources :report_variable, :only => %i[new edit update create destroy]
      resources :report_output, :only => %i[new edit update create destroy]
    end

    resources :connection, :only => %i[new show update destroy] do
      member do
        get :authenticate
        get :schedule_data_pull
      end

      collection do
        get :fitbit

        namespace :oauth, :module => nil do
          get :fitbit, :action => :fitbit_oauth
        end
      end
    end

    post "/query/execute", :to => "query#execute"
  end

  namespace :api do
    namespace :v1 do
      resources :token, :only => %i[create]
      resources :books, :only => %i[index]
    end
  end
end
# rubocop:enable Metrics/BlockLength
