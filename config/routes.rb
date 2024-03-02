Rails.application.routes.draw do
    namespace :api do
        resources :articles, param: :slug, only: [:create, :show, :update, :destroy]
    end
end
