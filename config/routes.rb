Rails.application.routes.draw do

  resources :visualizers
  # devise_for :accounts
  devise_for :accounts, controllers: { invitations: 'admin/invitations' }
  get '/admin/users/', to: 'admin/users#index'
  get '/admin/users/new', to: 'admin/users#new'
  get '/admin/users/:id', to: 'admin/users#show'
  delete '/admin/users/:id', to: 'admin/users#destroy'
  post '/admin/users/new', to: 'admin/users#create'
  get '/admin/users/invite/:token', to: 'admin/users#showcode'


  post '/admin/users/edit', to: 'admin/users#editRole'
  delete '/admin/users/dr/:id', to: 'admin/users#destroyRole'
  get '/admin/users/newrole', to: 'admin/users#newrole'
  post '/admin/users/newrole', to: 'admin/users#createRole'

  get '/admin/categories/', to: 'admin/categories#index'
  post '/admin/categories/edit', to: 'admin/categories#update'
  post '/admin/categories/new', to: 'admin/categories#new'

  get '/admin/apps/', to: 'admin/apps#index'
  post '/admin/apps/search', to: 'admin/apps#search'
  post '/admin/apps/hide', to: 'admin/apps#hide'
  post '/admin/apps/pass', to: 'admin/apps#pass'

  get '/admin/tasks/', to: 'admin/tasks#index'
  post '/admin/tasks/search', to: 'admin/tasks#search'
  get '/admin/tasks/:id', to: 'admin/tasks#view'
  delete '/admin/tasks/:id', to: 'admin/tasks#destroy'


  resources :categories do
    
  end

  resources :apps do
    
  end

  resources :projects do
    resources :samples do
      collection do
        post :import 
        post :import_abd_table
      end
      member do
        post :upload_seq
        post :upload_abd
        get :download_seq
        get :download_abd
      end
    end
    collection { post :import}
    collection { post :download_selected_file }
    collection { post :export_selected }
    member { post :download_abd_table} 
  end

  resources :samples do
    collection do
      post :make_selected_file
    end
  end

  resources :users do
    resources :tasks
  end
  post  'data-file-upload', to: 'users#data_file_upload', format: 'json'
  post  'data-file-attach', to: 'users#data_file_attach'
  post  'data-file-info', to: 'users#data_file_info', format: 'json'
  post  'data-file-delete', to: 'users#data_file_delete', format: 'json'
  post  'data-file-rename', to: 'users#data_file_rename', format: 'json'
  get 'all-categories', to: 'categories#all_categories', format: 'json'
  post 'apps-info', to: 'apps#apps_info', format: 'json'
  post 'create-task', to: 'tasks#create', format: 'json'
  post '/users/:user_id/tasks/tasks-info', to: 'tasks#tasks_info', format: 'json'
  post '/task-page', to: 'tasks#task_page'
  # post '/users/:user_id/tasks/task-status', to: 'tasks#task_status', format: 'json'

  # get 'welcome/index'
  root 'welcome#index'

  get "welcome", to: 'welcome#index', as: "welcome"

  # get 'tutorial', to: 'welcome#tutorial', as: 'tutorial'
  get 'contact', to: 'welcome#contact', as: 'contact'
  get 'docs', to: redirect('docs/index.html')

  # read local csv file 
  # get 'data/:name', to: 'raw_files#index'
  get 'api/local', to: 'raw_files#index'
  get 'api/public', to: 'raw_files#public'

  # draw on overview page
  

  namespace :api do
    resources :analysis, only: [] do
      get 'use_demo', to: 'viz_files#use_demo', as: 'use_demo'
      get 'use_task_output', to: 'viz_files#use_task_output', as: 'use_task_output'
      get 'all_files', to: 'viz_files#all_files', as: 'all_files'
      get 'all_task_outputs', to: 'viz_files#all_task_outputs', as: 'all_task_outputs'
      get 'chosen_files', to: 'viz_files#get_chosen_files', as: 'chosen_files'
      get 'chosen_file_paths', to: 'viz_files#chosen_file_paths', as: 'chosen_file_paths'
      get 'download_demo_file', to: 'viz_files#download_demo_file', as: 'download_demo_file'
      post 'chosen_files', to: 'viz_files#update_chosen_files', as: 'update_chosen_files'
      post 'create_files', to: 'viz_files#create_files', as: 'create_files'
      post 'batch_delete_files', to: 'viz_files#batch_delete_files', as: 'batch_delete_files'
    end
  end

  # database pages
  get 'database/overview', to: 'database#overview'
  get 'demo', to: 'demo#index'
  get 'demo/:id', to: 'demo#index'
  get 'applist', to: 'applist#index'
  get 'applist/:id', to: 'applist#index'
  
  scope '/visualizer' do
    resources :analysis
  end

  # submit pages
  # # < SUBMIT > Added by Alex
  post 'submit/api', to: 'tasks#submit_task', as: 'submit_api', format: 'json'
  # # End of useful things
  get "submit/analyses", to: "tasks#analyses"
  get "submit/pipelines", to: "tasks#pipelines"
  get 'submit/job-query', to: 'tasks#query', as: 'query'
  get 'submit/pipeline/:id', to: 'tasks#pipeline', as: 'submit_pipeline'
  
  
  # post 'submit-app-task', to: 'tasks#submit_app_task', format: 'json'
  # # < QUERY > Added by Alex
  post 'query/api', to: 'tasks#query_task', as: 'query_api', format: 'json'
  post 'query/status/api', to: 'tasks#query_task_status', as: 'query_status_api', format: 'json'
  # # End of useful things
  post 'query-app-task', to: 'tasks#query_app_task', format: 'json'
  post 'query-all-tasks', to: 'tasks#query_all', format: 'json'
  post 'remove-task', to: 'tasks#remove_task', format: 'json'

  # admin
  get '/admin', to: 'admin#index', as: "admin"
  post "admin/modify_sample_metadata" => "admin#modify_sample_metadata", :as => "admin/modify_sample_metadata"
  post "admin/modify_sample_abd" => "admin#modify_sample_abd", :as => "admin/modify_sample_abd"
  post "admin/modify_viz" => "admin#modify_viz", :as => "admin/modify_viz"
  post "admin/modify_ana_cate" => "admin#modify_ana_cate", :as => "admin/modify_ana_cate"
  post "admin/modify_ana" => "admin#modify_ana", :as => "admin/modify_ana"
  post "admin/modify_viz_source" => "admin#modify_viz_source", :as => "admin/modify_viz_source"
  post "admin/add_img" => "admin#add_img", :as => "admin/add_img"
  post "admin/update_all_samples" => "admin#update_all_samples", :as => "admin/update_all_samples"

  namespace :admin do
    post :update_analysis_category_position, to: 'analysis_categories#update_position'
    resources :analysis_categories, except: :show do
      resources :analyses, expect: %i[indewx show]
    end
    get 'analyses', to: 'analyses#index'
    # get 'visualizers', to: 'visualizers#index'
    resources :visualizers
    resources :analysis_pipelines
  end

  # serve files
  match 'data/uploads/*path', to: 'raw_files#uploads', as: 'get_uploads', via: :get
  match 'data/demo/*path', to: 'raw_files#demo', as: 'get_demo', via: :get
  match 'data/outputs/*path', to: 'raw_files#outputs', as: 'get_outputs', via: :get
  match 'data/static_viz_data/*path', to: 'raw_files#viz_file', via: :get
  match 'app/data/abd_files/*path', to: 'raw_files#viz_abd_file', via: :get

  # Application 
  get 'apps/details/:id', to: 'apps#details', as: 'check_detail_app'
  get 'apps/operate/offshelf/:id', to: 'apps#downgrade', as: 'offshelf_app'
  get 'apps/operate/onshelf/:id', to: 'apps#upgrade', as: 'onshelf_app'
  get 'apps/new', to: 'apps#new', as: 'createnew_app'
  resources :apps

end
