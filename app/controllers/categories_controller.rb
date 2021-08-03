class CategoriesController < ApplicationController
    before_action :set_category, only: [:show, :edit, :update, :destroy]

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
