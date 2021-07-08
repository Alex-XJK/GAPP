class UsersController < ApplicationController
    http_basic_authenticate_with name: "admin", password: "gapp"
    $user_stor_dir = "#{Rails.root}/data/user"

    def index
        @projects = App.order(:name)
        @ana_cate = Analysis.order(:name)
        @ac_attrs = Analysis.column_names
        @viz = Task.order(:name)
        @viz_attrs = Task.column_names
        @ana = Analysis.order(:name)
        @a_attrs = Analysis.column_names

        @users = User.select(:id, :username, :created_at)
        @usercolumn = ["id", "username", "created_at"] 
    end

    def show
        id = session[:user_id]
        @user = User.find(id)
    end


    def add_data_to_set(file_dict, dataset_name)
        id = session[:user_id]
        @user = User.find(id)
        user_dir = File.join($user_stor_dir, id)
        dataset_dir = File.join(user_dir, dataset_name)
        file_dict.keys.each do |key|
            file_path = File.join(dataset_dir, key)
            file = File.open(file_path, "w")
            file.write(file_dict[key])
            file.close
        end

    end

    
end
