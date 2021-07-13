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

    private

    def name_params
        params.permit(:id, :name)
    end
end
