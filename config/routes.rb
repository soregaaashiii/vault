Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "business_cards#index"

  resource :session, only: %i[new create destroy]
  get "trash" => "trash#index", as: :trash
  resource :system_settings, only: %i[show update]
  resources :organizations, except: %i[show destroy] do
    member do
      patch :archive
      patch :restore
      patch :destroy_as_archive
    end
  end
  resources :users, except: %i[show destroy] do
    member do
      patch :archive
      patch :restore
    end
  end
  resources :business_cards, only: :index

  resources :companies, except: :destroy do
    collection { get :trash }
    member do
      patch :archive
      patch :restore
    end
  end

  resources :contacts, except: :destroy do
    collection do
      get :trash
      get :scan
      post :create_from_card
    end
    member do
      patch :archive
      patch :restore
    end
    resources :business_cards, only: %i[create destroy] do
      member { patch :restore }
    end
    resources :contact_notes, only: %i[create destroy] do
      member { patch :restore }
    end
  end
end
