# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :admin_users unless Rails.env.test?
  namespace :admin do
    resource :categories, only: [] do
      get  :tree
      post :sort
    end
    resources :categories
    resources :concepts
    resource :data_elements, only: [] do
      get  :import
      post :import, to: 'data_elements#do_import'
    end
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
