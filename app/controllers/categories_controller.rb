class CategoriesController < ApplicationController
    http_basic_authenticate_with name: "admin", password: "gapp"

    def index
        @cats = Category.select(:id, :name, :created_at) 
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

    private

    def name_params
        params.permit(:id, :name)
    end

    def new_params
        params.permit(:name)
    end
end
