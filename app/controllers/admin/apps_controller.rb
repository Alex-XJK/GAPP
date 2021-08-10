class Admin::AppsController < ApplicationController
    http_basic_authenticate_with name: "gappdev", password: "hyqxjkzx"

    def index
        @cats = Category.select(:id, :name, :created_at) 
        @apps = App.select(:id, :app_no, :name, :user_id, :updated_at, :category_id, :status)
        @app_attrs = ["app_no", "name", "user_id", "updated_at"]
        @users = User.select(:id, :username)
    end

    def search
        @input_str = params[:name]
        @results = App.where('lower(name) LIKE ?', '%' + @input_str.downcase() + '%').all
        
        @cats = Category.select(:id, :name, :created_at) 
        @apps = App.select(:id, :app_no, :name, :user_id, :updated_at, :category_id)
        @app_attrs = ["app_no", "name", "user_id", "updated_at"]
        @users = User.select(:id, :username)
    end

end
