# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  resources :users, only: %i[show] do
    resources :followings, only: %i[create destroy], controller: 'follows'
    resources :clock_ins, path: 'clock-ins', only: %i[index], controller: 'clock_ins' do
      collection do
        post 'wake', to: 'clock_ins#wake'
        post 'sleep', to: 'clock_ins#sleep'
      end
    end
  end
end
