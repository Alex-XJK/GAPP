Rails.application.routes.draw do

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
    resources :datasets do
      member { post :upload_file }
      member { get :download_file}
      member { get :download_ds_abd}
      member { get :download_ds_metadata}
      member { post :delect_sample}
    end
  end

  # get 'welcome/index'
  post 'query_app_task_dummy', to: 'submit#query_app_task_dummy'
  post 'submit_app_task_dummy', to: 'submit#submit_app_task_dummy'
  root 'welcome#index'
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
  get 'demo', to: 'demo#show'
  
  scope '/visualizer' do
    resources :analysis
  end

  # submit pages
  get "submit/analyses", to: "submit#analyses"
  get "submit/pipelines", to: "submit#pipelines"
  get 'submit/job-query', to: 'submit#query', as: 'query'
  get 'submit/analysis/:id', to: 'submit#index', as: 'submit_analysis'
  get 'submit/pipeline/:id', to: 'submit#pipeline', as: 'submit_pipeline'
  
  
  # post 'submit-app-task', to: 'submit#submit_app_task', format: 'json'
  post 'query-app-task', to: 'submit#query_app_task', format: 'json'
  # post 'query-app-task-dummy', to: 'submit#query_app_task_dummy', format: 'json'
  post 'submit-app-task', to: 'submit#submit_app_task', format: 'json'
  post 'query-all-tasks', to: 'submit#query_all', format: 'json'
  post 'remove-task', to: 'submit#remove_task', format: 'json'

  # admin
  get '/admin', to: 'admin#index'
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

end
