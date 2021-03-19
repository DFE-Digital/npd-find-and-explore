# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :admin_users, path: 'admin/users', skip: %i[registrations]
  as :admin_user do
    get    '/admin/users/profile',        to: 'devise/registrations#edit',   as: :admin_user_root
    get    '/admin/users/edit(.:format)', to: 'devise/registrations#edit',   as: :edit_admin_user_registration
    patch  '/admin/users(.:format)',      to: 'devise/registrations#update', as: :admin_user_registration
    put    '/admin/users(.:format)',      to: 'devise/registrations#update'
    delete '/admin/users(.:format)',      to: 'devise/registrations#destroy'
    post   '/admin/users(.:format)',      to: 'devise/registrations#create'
  end

  namespace :admin do
    resource :categories, only: [] do
      get  :tree
      get  :childless
      post :sort
      get  :import
      post :preprocess
      post :import, to: 'categories#do_import'
      post :abort_import
      get  :export
      get  :download
    end
    resources :categories
    resource :concepts, only: [] do
      get  :childless
    end
    resources :concepts, except: %i[index]
    resource :data_elements, only: [] do
      get  :orphaned
      post :orphaned, to: 'data_elements#assign_orphaned'
      get  :reindex
      post :reindex, to: 'data_elements#do_reindex'
    end
    resources :data_elements, only: %i[index show]
    resource :import_datasets, only: [] do
      get  'import(/:id)',       to: 'import_datasets#import',
                                 as: :import
      post :preprocess
      get  'recognised/:id',     to: 'import_datasets#recognised',
                                 as: :recognised
      post 'recognised/:id',     to: 'import_datasets#preprocess_recognised'
      get  'unrecognised/:id',   to: 'import_datasets#unrecognised',
                                 as: :unrecognised
      post 'unrecognised/:id',   to: 'import_datasets#preprocess_unrecognised'
      get  'summary/:id',        to: 'import_datasets#summary',
                                 as: :summary
      post 'import/:id',         to: 'import_datasets#do_import'
      get  'abort_import(/:id)', to: 'import_datasets#abort_import',
                                 as: :abort_import
    end
    resources :datasets
    resources :admin_users
    resource :admin_user, only: [] do
      put ':id/deactivate', to: 'admin_users#deactivate', as: :deactivate
      put ':id/reactivate', to: 'admin_users#reactivate', as: :reactivate
    end
    resources :uploads, only: %i[index]

    root to: 'home#index'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '(/:locale)', locale: /en|cy/, defaults: { locale: 'en' } do
    resources :categories,    only: %i[index show]
    resources :concepts,      only: %i[show]
    resources :data_elements, only: %i[show]
    resource :datasets,       only: [] do
      get 'data_elements/:id', to: 'datasets#data_elements'
    end
    resources :datasets,      only: %i[show]
    resources :search,        only: %i[index]
    resources :saved_items,   only: %i[index]
    resource :saved_items,    only: [] do
      post 'saved_items', to: 'saved_items#saved_items'
      post 'export_to_csv', to: 'saved_items#export_to_csv'
    end
  end
end
