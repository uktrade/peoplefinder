# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#show', as: :home

  post '/report_problem', to: 'report#index'

  namespace :api, format: [:json] do
    resource :people, only: [:show]
    match '/search', to: 'search#index', via: [:get]
  end

  resources :profile_photos, only: [:create]

  resources :groups, path: 'teams' do
    resources :groups, only: [:new]
    get :people, on: :member, action: 'all_people'
    get :"people-outside-subteams", on: :member, action: 'people_outside_subteams'
  end

  resources :people, except: %i[new create] do
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
  match '/audit_trail/undo/:id', to: 'versions#undo', via: [:post]
  match '/search', to: 'search#index', via: [:get]

  get '/groups/:id', to: redirect('/teams/%{id}')
  get '/groups/:id/edit', to: redirect('/teams/%{id}/edit')
  get '/groups/:id/people', to: redirect('/teams/%{id}/people')

  namespace :metrics do
    resources :activations, only: [:index]
    resources :completions, only: [:index]
    resources :profiles, only: [:index]
    resources :team_descriptions, only: [:index]
  end

  namespace :admin do
    root to: 'management#show', as: :home
    get 'user_behavior_report', controller: 'management', action: :user_behavior_report
    get 'generate_user_behavior_report', controller: 'management', action: :generate_user_behavior_report
    resource :profile_extract, only: [:show]
    resource :team_extract, only: [:show]
  end

  get '/my/profile', to: 'home#my_profile'
  get '/cookies', to: 'pages#show', id: 'cookies', as: :cookies

  health_check_routes
end
