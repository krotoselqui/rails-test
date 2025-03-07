Rails.application.routes.draw do
  # OmniAuthのコールバックルート
  get '/auth/google_oauth2/callback', to: 'sessions#google_oauth2_callback'
  delete '/unlink/google', to: 'sessions#unlink_google', as: :unlink_google
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # 認証関連のルート
  get '/login', to: 'sessions#new', as: :login
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout

  # ユーザー関連のルート
  get '/signup', to: 'users#new', as: :signup
  resources :users, except: [:index, :destroy, :new] do
    member do
      get 'google_drive'
      post 'create_google_drive_folder'
      post 'upload_to_google_drive'
    end
  end

  # productsに関してCRUDアクションを定義する
  resources :products

  root "firestore#index"
  get '/firestore', to: 'firestore#index', as: :firestore_index  # 一覧表示
  get '/firestore/new', to: 'firestore#new', as: :firestore_new  # 新規作成フォーム
  post '/firestore/create', to: 'firestore#create', as: :firestore_create  # データ作成
  get '/firestore/:collection/:id', to: 'firestore#show', as: :firestore_show  # ドキュメントの取得
  get '/firestore/:collection/:id/edit', to: 'firestore#edit', as: :firestore_edit  # 編集フォーム
  patch '/firestore/:collection/:id', to: 'firestore#update', as: :firestore_update  # データ更新
  delete '/firestore/:collection/:id', to: 'firestore#destroy', as: :firestore_destroy  # ドキュメントの削除
end
