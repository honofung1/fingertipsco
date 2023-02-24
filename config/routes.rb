Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Temp method for now
  # redirect the root page to admin login page
  # TODO
  # for the security, when someone try to access the root directory
  # it should redirect to the blank page instead of redirect to login page
  root to: redirect("/admin/login"), as: :redirected_root

  # TODO: rename admin to admins
  # need testing
  namespace :admin do
    # Login Session
    get '/' => 'dashboards#index', as: :dashboard
    root 'dashboards#index', as: :root
    get 'login', to: 'user_sessions#new'
    post 'login', to: 'user_sessions#create'
    delete 'logout', to: 'user_sessions#destroy'

    # Manage Admin user
    resources :admins

    # Manage Deposit record
    resources :deposit_records

    # Manage import file task
    resources :file_import_tasks

    # Manage Order Owner
    resources :order_owners do
      # Manage the orders belongs to its order owner
      resources :orders do
        member do
          get 'clone'
        end
      end
    end

    # Manage Order and its part
    resources :orders do
      member do
        get 'clone'
      end
    end

    # Manage Report
    resources :reports do
      member do
        get 'download'
      end
    end

    # Manage System Setting
    resources :system_settings ,:except => [:edit,:update, :show] do
      collection do
        get :edit_multiple
        put :update_multiple
      end
    end

    # Manage the fingertips vintage parts
    # TODO: temp to remove due to not start working on that parts
    # we block the access of that url for now
    # resources :inventorys
  end

  namespace :vendor do
    # Login Session
    # get '/' => 'dashboards#index', as: :dashboard
    # root 'dashboards#index', as: :root
    # get 'login', to: 'user_sessions#new'
    # post 'login', to: 'user_sessions#create'
    # delete 'logout', to: 'user_sessions#destroy'

    # resources :key_accounts
  end
end
