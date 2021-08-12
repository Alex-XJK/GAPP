class Admin::CategoriesController < ApplicationController
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
        @cats = Category.select(:id, :name, :created_at).order(:id)
        @cat_attrs = ["id", "name", "created_at"] 
    end

    def update
        @cat = Category.find(params[:id])
        @cat.update(name_params)
    end

    def new
        @cat = Category.new(name: new_params["name"])
        @cat.save()
        redirect_to action: "index"
    end

    def all_categories
        @cats = Category.all
        options = []
        result_json = {
            code: false,
            data:[]
        }
        @cats.each do |c|
            options.push({
                value: c.id,
                label: c.name
            })
        end
        result_json[:code] = true
        result_json[:data] = options
        render json: result_json
    end

    private

    def name_params
        params.permit(:id, :name)
    end

    def new_params
        params.permit(:name)
    end
end
