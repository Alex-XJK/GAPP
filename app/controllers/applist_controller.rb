class ApplistController < ApplicationController
    
    def index
      @categories = Category.select(:id, :name, :created_at) 
      @apps = App.select(:id, :app_no, :description, :name, :user_id, :updated_at, :category_id)
      @app_attrs = ["app_no", "name", "user_id", "updated_at"]
      @users = User.select(:id, :username)
      @id = params[:id]
    end

  end
  
