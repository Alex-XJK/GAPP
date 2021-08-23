class Admin::AppsController < ApplicationController
    before_action :authenticate_account!
    before_action :require_admin

    # http_basic_authenticate_with name: "gappdev", password: "hyqxjkzx"

    def require_admin
        unless account_signed_in? and current_account.has_role? :admin
          flash[:error] = "You must be an admin to access this page. (Current role: " + current_account.roles.first.name + ")"
          redirect_to "/" # halts request cycle
        end
    end

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
