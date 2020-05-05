# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  root 'home#show', as: :home

  post '/report_problem', to: 'report#create'

  namespace :api, format: [:json] do
    resource :people, only: [:show]

    namespace :v2 do
      resources :people, only: [:show]
    end
  end

  resources :profile_photos, only: [:create]

  resources :groups, except: [:index], path: 'teams' do
    resources :groups, only: [:new]

    member do
      get :all_people, path: 'people', as: 'people'
      get :people_outside_subteams, path: 'people-outside-subteams', as: 'people_outside_subteams'
      get :tree
    end
  end

  # TODO: index action can also be removed, but this causes issues with the legacy
  #   people form so needs to wait for people to be on new frontend
  resources :people, except: %i[new create] do
    member do
      put :confirm
    end

    collection do
      get :add_membership
    end

    resource :image, controller: 'person_image', only: %i[edit update]
    resource :email, controller: 'person_email', only: %i[edit update]
    resource :deletion_request, controller: 'person_deletion_request',
                                path: 'deletion-request',
                                only: %i[new create]
  end

  resource :sessions, only: %i[new create destroy]

  match '/auth/:provider/callback', to: 'sessions#create', via: %i[get post]
  match '/audit_trail', to: 'versions#index', via: [:get]
  match '/audit_trail/undo/:id', to: 'versions#undo', via: [:post], as: :audit_trail_undo
  match '/search', to: 'search#index', via: [:get]
  match '/search/people.json', to: 'search#people', via: [:get]

  namespace :admin do
    root to: 'management#show', as: :home

    resource :profile_extract, only: [:show]
    resource :team_extract, only: [:show]

    constraints AdminRouteConstraint.new do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  get '/my/profile', to: 'home#my_profile'

  health_check_routes
end
