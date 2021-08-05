class Admin::AppsController < ApplicationController
    http_basic_authenticate_with name: "gappdev", password: "hyqxjkzx"

    def index
        @cats = Category.select(:id, :name, :created_at) 
        @apps = App.select(:id, :app_no, :name, :user_id, :updated_at, :category_id, :status)
        @app_attrs = ["app_no", "name", "user_id", "updated_at"]
        @users = User.select(:id, :username)
    end

    def search
        @results = App.where(name: params[:name])
        @cats = Category.select(:id, :name, :created_at) 
        @apps = App.select(:id, :app_no, :name, :user_id, :updated_at, :category_id)
        @app_attrs = ["app_no", "name", "user_id", "updated_at"]
        @users = User.select(:id, :username)
    end

    def apps_info
        @apps = App.where(category_id: params[:cate])
        result_json = {
            code: false,
            data:[]
        }
        return_apps = []
        @apps.each do |a|
            return_apps.push({
                Id: a.id,
                name: a.name,
                cate: a.category_id
            })
        end
        result_json[:code] = true
        result_json[:data] = return_apps
        render json: result_json
    end

end
