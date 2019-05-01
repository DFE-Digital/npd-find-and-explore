# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :admin_users unless Rails.env.test?
  namespace :admin do
    resources :categories
    resources :concepts
    resources :data_elements, only: %i[index show]
    resources :admin_users, only: %i[index show]

    root to: 'categories#index'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '(/:locale)', locale: /en|cy/, defaults: { locale: 'en' } do
    resources :categories, only: %i[index show]
    resources :concepts, only: %i[show]
    resources :search, only: %i[index]
  end
end
