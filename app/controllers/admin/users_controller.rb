class Admin::UsersController < ApplicationController
    before_action :authenticate_account!
    before_action :require_admin
    
    # http_basic_authenticate_with name: "gappdev", password: "hyqxjkzx"
    $user_stor_dir = "#{Rails.root}/data/user"

    def require_admin
        unless account_signed_in? and current_account.has_role? :admin
          flash[:error] = "You must be an admin to access this page. (Current role: " + current_account.roles.first.name + ")"
          redirect_to "/" # halts request cycle
        end
    end

    def index
        @projects = App.order(:name)
        @ana_cate = Analysis.order(:name)
        @ac_attrs = Analysis.column_names
        @ana = Analysis.order(:name)
        @a_attrs = Analysis.column_names

        @users = User.all
        @accounts = Account.all
        @usercolumn = ["id", "username", "role_id", "created_at"]
        @usercolumnname = ["id", "name", "role", "register time"]
        @roles = Role.select(:id, :name)
    end

    def show
        @uid = params[:id]
        @flag = false
        if User.find(params[:id]).account_id == nil
            @user = User.find(params[:id])
            @user_attrs = User.column_names
        else
            @user = Account.find(User.find(params[:id]).account_id)
            @user_attrs = Account.column_names
            @flag = true
        end
    end

    def showcode
        @tk = params[:token]
    end

    def destroy
        @usr = User.find(params[:id])
        if @usr.account_id == nil
            @tapps = App.where({ user_id: params[:id] })
            for uapp in @tapps
                uapp.user_id = 1
                uapp.save(:validate => false)
            end
            @user = User.find(params[:id])
            @user.destroy
            redirect_to action: "index"
        else
            if Account.find(@usr.account_id).has_role? :admin
                flash[:error] = "Operations on admin account is not allowed." 
                redirect_to action: "index"
            else
                @bkid = @usr.account_id
                @tapps = App.where({ user_id: params[:id] })
                for uapp in @tapps
                    uapp.user_id = 1
                    uapp.save(:validate => false)
                end
                @user = User.find(params[:id])
                @user.destroy
                Account.find(@bkid).destroy
                redirect_to action: "index"
            end
        end
    end

    def destroyRole
        @role = Role.find(params[:id])
        @role.destroy

        redirect_to action: "index"
    end

    def editRole
        @usr = User.find(params[:id])
        if @usr.account_id == nil
            @usr.update(edit_params)
        else
            @user = Account.find(@usr.account_id)
            if @user.roles.first.name == "admin"
                flash[:error] = "Operations on admin account is not allowed." 
                redirect_to action: "index"
            else
                @usr.update(edit_params)
                @user.roles = []
                if params[:role_id] == "1"
                    @user.add_role(:admin)
                else
                    if params[:role_id] == "2"
                        @user.add_role(:producer)
                    else
                        @user.add_role(:user)
                    end
                end
            end
        end
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
        Rails.logger.debug "=====>#{@user.id}"
        # redirect_to action: "index" and return
        redirect_to action: "index"
        
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
        params.require(:user).permit(:username, :password_digest, :role_id)
    end

    def role_params
        params.permit(:authenticity_token, :uid, :name, :app_id, :commit)
    end
    
    def edit_params
        params.permit(:id, :role_id)
    end
    
end
