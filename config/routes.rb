Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Temp method for now
  # redirect the root page to admin login page
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

    # Mange Admin user
    resources :admins

    # Manage Order Owner
    resources :order_owners

    # Manage Order and its part
    resources :orders do
      member do
        get 'clone'
      end
    end

    # Mange Report
    resources :reports do
      member do
        get 'download'
      end
    end

    # Manage the import task
    resources :file_import_tasks

    # Manage the fingertips vintage parts
    # TODO: temp to remove due to not start that parts
    # we block the access of that url for now
    # resources :inventorys
  end
end
