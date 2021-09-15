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
        @apponline = App.where(status: 'online')
        @appaudit = App.where(status: 'audit')
        @appoffline = App.where(status: 'offline')
    end

    def search
        @input_str = params[:name]
        @results = App.where('lower(name) LIKE ?', '%' + @input_str.downcase() + '%').all
        
        @cats = Category.select(:id, :name, :created_at) 
        @apps = App.select(:id, :app_no, :name, :user_id, :updated_at, :category_id)
        @app_attrs = ["app_no", "name", "user_id", "updated_at"]
        @users = User.select(:id, :username)
    end

    def hide
        @apponline = App.where(status: 'online')
        for el in @apponline
            if params[String(el.id)] == "on"
                el.update(status: 'offline')
            end
        end
        redirect_to action: "index"
    end

    def pass
        @appaudit = App.where(status: 'audit')
        for el in @appaudit
            if params[String(el.id)] == "on"
                el.update(status: 'online')
            end
        end
        redirect_to action: "index"
    end

end
