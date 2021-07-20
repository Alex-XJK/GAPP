class Admin::TasksController < ApplicationController

    def index
        @cats = Category.select(:id, :name, :created_at) 
        @apps = App.select(:id, :app_no, :name, :user_id, :updated_at, :category_id)
        @app_attrs = ["app_no", "name", "user_id", "updated_at"]
        @users = User.select(:id, :username)
        @tasks = Task.select(:id, :user_id, :created_at, :status, :app_id)
        @task_attrs = ["id", "user_id", "created_at", "status"]
    end

    def search
        @results = Task.where(id: params[:id])
        @users = User.select(:id, :username)
        @task_attrs = ["id", "user_id", "created_at", "status"]
    end

    def destroy
        @tsk = Task.find(params[:id])
        @tsk.destroy
        redirect_to action: "index"
    end

    def view
        @task = Task.find(params[:id])
        @task_attrs = Task.column_names
    end
end
