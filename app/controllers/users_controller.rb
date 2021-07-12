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
        @roles_attrs = ["id", "name", "app_id"]
        @roles = Role.where({ id: UserRole.where({ user_id: params[:id] }).select(:role_id) }).select(@roles_attrs)
        id = params[:id]
        @user = User.find(id)
    end

    def destroy
        @user = User.find(params[:id])
        @user.destroy
    
        redirect_to action: "index"
    end

    def destroyRole
        @role = Role.find(params[:id])
        @role.destroy

        redirect_to action: "index"
    end


    def new
        @user = User.new
    end

    def newRole
        @role = Role.new
    end

    def createRole
        @role = Role.new(name: role_params["name"], app_id: role_params["app_id"])
        @role.save()
        @userrole = UserRole.new(user_id: role_params["uid"], role_id: @role.id)
        @userrole.save()
    end

    def create
        @user = User.new(user_params)
        @user.save()
        redirect_to action: "index" and return
        
    end

    def edit
        @roles_attrs = ["id", "name", "app_id"]
        @roles = Role.where({ id: UserRole.where({ user_id: params[:id] }).select(:role_id) }).select(@roles_attrs)
        @user = User.find(params[:id])

    end
        
    def update
            @user = User.find(params[:id])
        
            if @user.update(user_params)
              redirect_to @user
            else
              render :edit
            end
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


    private

    def user_params
        params.require(:user).permit(:username, :password_digest)
    end

    def role_params
        params.permit(:authenticity_token, :uid, :name, :app_id, :commit)
    end
    
    
end
