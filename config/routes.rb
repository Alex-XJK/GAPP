Rails.application.routes.draw do
  # get 'welcome/index'
  root 'welcome#index'
  # get 'tutorial', to: 'welcome#tutorial', as: 'tutorial'
  get 'contact', to: 'welcome#contact', as: 'contact'
  get 'docs', to: redirect('docs/index.html')


  # database pages
  get 'database/sample'
  get 'database/tc'
  get 'database/char'
  get 'database/fc'
  get 'database/aa'
  
  # submit pages
  get 'submit/:id', to: 'submit#index', as: 'submit'
  get 'job-query', to: 'submit#query', as: 'query'
  post 'submit-app-task', to: 'submit#submit_app_task', format: 'json'
  post 'query-app-task', to: 'submit#query_app_task', format: 'json'
  mount Deltadb::Engine => "/db"
end
