class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
    
    def index
        @users = User.all
    end

    def show
        gon.push(user_id: @user.id)
    end

    def new
        @user = User.new
    end

    def edit
    end

    def create
        @user = User.new(user_params)
    
        respond_to do |format|
            if @user.save
                format.html { redirect_to @user, notice: 'User was successfully created.' }
                format.json { render :show, status: :created, location: @user }
            else
                format.html { render :new }
                format.json { render json: @user.errors, status: :unprocessable_entity }
            end
        end
    end

    def update
        respond_to do |format|
            if @user.update(user_params)
                format.html { redirect_to @user, notice: 'User was successfully updated.' }
                format.json { render :show, status: :ok, location: @user }
            else
                format.html { render :edit }
                format.json { render json: @user.errors, status: :unprocessable_entity }
            end
        end
    end

    def destroy
        @user.destroy
        respond_to do |format|
            format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
            format.json { head :no_content }
        end
    end

    def data_file_upload
        result_json = {
            code: false
        }
        @user = User.find(params[:id])
        Rails.logger.debug "Here is #{@user}"
        @user.dataFiles = params[:dataFiles]
        if @user.save
            result_json[:code] = true
        end
        render json: result_json
    end

    def data_file_info
        @user = User.find(params[:id])
        result_json = {
            code: false,
            data:[]
        }
        dataInfo = []
        @user.dataFiles.each do |f|
            dataInfo.push({
                dataId: f.id,
                name: f.filename.to_s,
                uploadTime: f.created_at
            })
        end
        result_json[:code] = true
        result_json[:data] = dataInfo
        render json: result_json
    end

    def data_file_delete
        @user = User.find(params[:id])
        result_json = {
            code: false
        }
        if @user.dataFiles.find(params[:dataId]).purge
            result_json[:code] = true
        end
        render json: result_json
    end

    def data_file_rename
        @user = User.find(params[:id])
        result_json = {
            code: false
        }
        dataFile = @user.dataFiles.find(params[:dataId])
        suffix = dataFile.filename.to_s.split('.')[1]
        newName = params[:newName] + '.' + suffix
        # Since there is only created_at, here used it as updated_at
        if (dataFile.blob.update!(filename: newName) &&
            dataFile.blob.update!(created_at: Time.now))
            result_json[:code] = true
        end
        render json: result_json
    end
        
    private
        def set_user
            @user = User.find(params[:id])
        end

        def user_params
            params.require(:user).permit(:username, :password_digest, dataFiles:[])
        end

end
