# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :admin_users if Rails.env.development?

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :categories, only: %i[index show]
  resources :concepts, only: %i[show]
  resources :search, only: %i[index]
end
