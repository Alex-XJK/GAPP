Rails.application.routes.draw do

  get 'test', to: 'demo#test'
  resources :projects do
    resources :samples do
      collection { post :import }
      collection { post :make_selected_file}
      collection { post :import_abd_table}
      member { post :upload_seq }
      member { post :upload_abd }
      member { get :download_seq }
      member { get :download_abd }
    end
    collection { post :import}
    collection { post :download_selected_file }
    collection { post :export_selected }
    member { post :download_abd_table} 
  end

  resources :users do 
    resources :datasets do
      member { post :upload_file }
      member { get :download_file}


    end
  end

  # get 'welcome/index'
  root 'welcome#index'
  # get 'tutorial', to: 'welcome#tutorial', as: 'tutorial'
  get 'contact', to: 'welcome#contact', as: 'contact'
  get 'docs', to: redirect('docs/index.html')

  # read local csv file 
  # get 'data/:name', to: 'raw_files#index'
  get 'api/local', to: 'raw_files#index'
  get 'api/public', to: 'raw_files#public'

  # draw on overview page
  get 'data/static_viz_data/:name', to: 'raw_files#viz_file'

  namespace :api do
    resources :analysis, only: [] do
      get 'use_demo', to: 'viz_files#use_demo', as: 'use_demo'
      get 'use_task_output', to: 'viz_files#use_task_output', as: 'use_task_output'
      get 'all_files', to: 'viz_files#all_files', as: 'all_files'
      get 'all_task_outputs', to: 'viz_files#all_task_outputs', as: 'all_task_outputs'
      get 'chosen_files', to: 'viz_files#get_chosen_files', as: 'chosen_files'
      get 'chosen_file_paths', to: 'viz_files#chosen_file_paths', as: 'chosen_file_paths'
      post 'chosen_files', to: 'viz_files#update_chosen_files', as: 'update_chosen_files'
      post 'create_files', to: 'viz_files#create_files', as: 'create_files'
      post 'batch_delete_files', to: 'viz_files#batch_delete_files', as: 'batch_delete_files'
    end
  end
  # database pages
  get 'database/sample'
  get 'database/tc'
  get 'database/char'
  get 'database/fc'
  get 'database/aa'
  get 'database/overview', to: 'database#overview'
  
  get 'demo', to: 'demo#show'
  
  scope '/visualizer' do
    resources :analysis
  end

  # submit pages
  get 'submit/viz', to: 'submit#viz'
  get 'submit/:id', to: 'submit#index', as: 'submit'
  get 'job-query', to: 'submit#query', as: 'query'
  
  post 'submit-app-task', to: 'submit#submit_app_task', format: 'json'
  post 'query-app-task', to: 'submit#query_app_task', format: 'json'
  post 'query-app-task-dummy', to: 'submit#query_app_task_dummy', format: 'json'
  mount Deltadb::Engine => "/db"

  # admin
  get '/admin', to: 'admin#index'
  post "admin/modify_sample_metadata" => "admin#modify_sample_metadata", :as => "admin/modify_sample_metadata"
  post "admin/modify_sample_abd" => "admin#modify_sample_abd", :as => "admin/modify_sample_abd"
  post "admin/modify_viz" => "admin#modify_viz", :as => "admin/modify_viz"
  post "admin/modify_ana_cate" => "admin#modify_ana_cate", :as => "admin/modify_ana_cate"
  post "admin/modify_ana" => "admin#modify_ana", :as => "admin/modify_ana"
  post "admin/modify_viz_source" => "admin#modify_viz_source", :as => "admin/modify_viz_source"
  post "admin/add_img" => "admin#add_img", :as => "admin/add_img"

  # serve files
  match '/data/uploads/*path', to: 'raw_files#uploads', as: 'get_uploads', via: :get
  match '/data/demo/*path', to: 'raw_files#demo', as: 'get_demo', via: :get

end
