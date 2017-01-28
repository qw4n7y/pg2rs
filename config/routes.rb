Rails.application.routes.draw do
  devise_for :users, class_name: "Users::User"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'application#welcome'
end
