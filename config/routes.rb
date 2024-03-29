Gdae::Application.routes.draw do
  devise_for :users
  get "ssl/index"
  get "ssl/about"
  get "ssl/admin"
  get "ssl/search"
  get "ssl/users"
  root "ssl#index"

  get '/ssl/promote_user/:promote_id', to: 'ssl#promote_user', as: 'promote'
  get '/find', to: 'doc#find', as: 'result'
  get '/doc/:id', to: 'doc#show', as: 'doc'
  get '/raw/:id', to: 'doc#raw', as: 'raw'
  get '/delete/:id', to: 'doc#delete', as: 'delete'
  get '/edit/:id', to: 'doc#edit', as: 'edit'
  get '/doc', to: 'doc#index', as: 'docs'
  get '/browse', to: 'doc#browse', as: 'browse'
  get '/get_data', to: 'doc#get_data', as: 'get_data'
  get '/results', to: 'doc#results', as: 'results'
  get '/search', to: 'doc#search', as: 'search'
  post '/doc/create', to: 'doc#create'
  post '/doc/update', to: 'doc#update'

  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
