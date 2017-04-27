require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, class_name: "Users::User"
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: 'imports/imports#index'

  resources :imports, module: 'imports', as: :imports_imports do
    resources :transfers, as: :imports_transfers
    resources :migrations, as: :migrations do
      post :start, on: :member
    end
    resources :exports, as: :exports do
      post :start, on: :member
    end
  end
end
