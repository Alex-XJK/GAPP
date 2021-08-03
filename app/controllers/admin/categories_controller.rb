class Admin::CategoriesController < ApplicationController
    http_basic_authenticate_with name: "gappdev", password: "hyqxjkzx"

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
