Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # TODO: rename admin to admins
  # need testing
  namespace :admin do
    # Login Session
    get '/' => 'dashboards#index', as: :dashboard
    root 'dashboards#index', as: :root
    get 'login', to: 'user_sessions#new'
    post 'login', to: 'user_sessions#create'
    delete 'logout', to: 'user_sessions#destroy'

    # Manage Order Owner
    resources :order_owners

    # Manage Order and its part
    resources :orders

    # Mange Admin user
    resources :admin_users

    # Mange Report
    resources :reports do
      member do
        get 'download'
      end
    end

  end
end
