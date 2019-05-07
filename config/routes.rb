# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :admin_users, skip: %i[registrations]
  as :admin_user do
    get    '/admin_users/profile',        to: 'devise/registrations#edit',   as: :admin_user_root
    get    '/admin_users/edit(.:format)', to: 'devise/registrations#edit',   as: :edit_admin_user_registration
    patch  '/admin_users(.:format)',      to: 'devise/registrations#update', as: :admin_user_registration
    put    '/admin_users(.:format)',      to: 'devise/registrations#update'
    delete '/admin_users(.:format)',      to: 'devise/registrations#destroy'
    post   '/admin_users(.:format)',      to: 'devise/registrations#create'
  end

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
    resources :admin_users

    root to: 'categories#index'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '(/:locale)', locale: /en|cy/, defaults: { locale: 'en' } do
    resources :categories, only: %i[index show]
    resources :concepts, only: %i[show]
    resources :search, only: %i[index]
  end
end
