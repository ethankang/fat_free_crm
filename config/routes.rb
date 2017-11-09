# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Gollum
  Gollum::GIT_ADAPTER = "rugged"
end
require 'gollum/app'

class App < Precious::App

  before { authenticate }

  helpers do
    def authenticate
      request.session[:init] = true
      user = User.find_by_id(request.session[:user_credentials_id])
      if user
        session["gollum.author"] = { :name => user.name, :email => user.email }
      else
        response["Location"] = "http://#{Setting.host}"
        throw(:halt, [302, "Found"])
      end
    end
  end

end

Rails.application.routes.draw do

  App.set(:gollum_path, Rails.root.join("db", "wiki").to_s)
  App.set(:default_markup, :markdown) # set your favorite markup language
  App.set(:wiki_options, {
    live_preview: false,
    allow_uploads: true,
    show_all: true,
    template_dir: Rails.root.join('app/views/wiki_template').to_s
  })
  mount App, at: 'wiki'

  resources :lists

  root to: 'home#index'

  get 'activities' => 'home#index'
  get 'admin'      => 'admin/users#index',       :as => :admin
  get 'login'      => 'authentications#new',     :as => :login
  get 'login_by_dingtalk'      => 'authentications#new_by_dingtalk',     :as => :login_by_dingtalk
  post 'create_by_dingtalk'      => 'authentications#create_by_dingtalk',     :as => :create_by_dingtalk
  delete 'logout'  => 'authentications#destroy', :as => :logout
  get 'profile'    => 'users#show',              :as => :profile
  get 'signup'     => 'users#new',               :as => :signup

  # 限制只有通过立返利服务器发出的请求才予以处理
  post '/api/create_lead' => "api#create_lead", constraints: ->(req){ req.remote_ip == "54.223.202.83"}

  get '/home/options',  as: :options
  get '/home/toggle',   as: :toggle
  match '/home/timeline', as: :timeline, via: [:get, :put, :post]
  match '/home/timezone', as: :timezone, via: [:get, :put, :post]
  post '/home/redraw',   as: :redraw

  resource :authentication, except: [:index, :edit]
  resources :comments,       except: [:new, :show]
  resources :emails,         only: [:destroy]
  resources :passwords,      only: [:new, :create, :edit, :update]

  resources :accounts, id: /\d+/ do
    collection do
      get :advanced_search
      post :filter
      get :options
      get :field_group
      match :auto_complete, via: [:get, :post]
      get :redraw
      get :versions
    end
    member do
      put :attach
      post :discard
      post :subscribe
      post :unsubscribe
      get :contacts
      get :opportunities
    end
  end

  resources :campaigns, id: /\d+/ do
    collection do
      get :advanced_search
      post :filter
      get :options
      get :field_group
      match :auto_complete, via: [:get, :post]
      get :redraw
      get :versions
    end
    member do
      put :attach
      post :discard
      post :subscribe
      post :unsubscribe
      get :leads
      get :opportunities
    end
  end

  resources :contacts, id: /\d+/ do
    collection do
      get :advanced_search
      post :filter
      get :options
      get :field_group
      match :auto_complete, via: [:get, :post]
      get :redraw
      get :versions
    end
    member do
      put :attach
      post :discard
      post :subscribe
      post :unsubscribe
      get :opportunities
    end
  end

  resources :leads, id: /\d+/ do
    collection do
      get :advanced_search
      post :filter
      get :options
      get :field_group
      match :auto_complete, via: [:get, :post]
      get :redraw
      get :versions
      get :autocomplete_account_name
    end
    member do
      get :convert
      post :discard
      post :subscribe
      post :unsubscribe
      put :attach
      match :promote, via: [:patch, :put]
      put :reject
    end
  end

  resources :opportunities, id: /\d+/ do
    collection do
      get :advanced_search
      post :filter
      get :options
      get :field_group
      match :auto_complete, via: [:get, :post]
      get :redraw
      get :versions
    end
    member do
      put :attach
      post :discard
      post :subscribe
      post :unsubscribe
      get :contacts
    end
  end

  resources :tasks, id: /\d+/ do
    collection do
      post :filter
      match :auto_complete, via: [:get, :post]
    end
    member do
      put :complete
      put :uncomplete
    end
  end

  resources :users, id: /\d+/, except: [:index, :destroy] do
    member do
      get :avatar
      get :password
      match :upload_avatar, via: [:put, :patch]
      patch :change_password
      post :redraw
    end
    collection do
      match :auto_complete, via: [:get, :post]
      get :opportunities_overview
    end
  end

  namespace :admin do
    resources :groups

    resources :users do
      collection do
        match :auto_complete, via: [:get, :post]
      end
      member do
        get :confirm
        put :suspend
        put :reactivate
      end
    end

    resources :field_groups, except: [:index, :show] do
      collection do
        post :sort
      end
      member do
        get :confirm
      end
    end

    resources :fields do
      collection do
        match :auto_complete, via: [:get, :post]
        get :options
        get :redraw
        post :sort
        get :subform
      end
    end

    resources :tags, except: [:show] do
      member do
        get :confirm
      end
    end

    resources :fields, as: :custom_fields
    resources :fields, as: :core_fields

    resources :settings, only: :index
    resources :plugins,  only: :index
  end
end
