class UsersController < ApplicationController
    before_action :authenticate_account!
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
        @users = User.all
    end

    def show
        gon.push(user_id: @user.id)
        # User and Visitor can view published apps
        # Producer can only check their own apps or other peoples' published apps
        # Admin do not have restrictions
        if account_signed_in?
            # Rails.logger.debug("current account id is #{current_account.id}, user.id is #{@user.id}, param is #{params[:id]}")
            # Rails.logger.debug("anser is #{params[:id].to_i != @user.id.to_i}")
            if params[:id].to_i != @user.id.to_i
                flash[:error] = "You should not visit other's profile page. Redirect to your own page"
                redirect_to user_path(@user.id)
            end
        else
            flash[:error] = 'You should login first'
            redirect_to root_path
        end
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
            code: false,
            msg: ''
        }
        canBeSave = false
        maxSize = 1024*1024
        @user = User.find(params[:id])
        # Rails.logger.debug "file size #{params[:dataFiles][0].size}"
        # Rails.logger.debug "Here is #{@user}"
        # Rails.logger.debug "size #{@user.dataFiles.length}"
        if params[:dataFiles].nil?
            result_json[:msg] = 'Empty file cannot be saved!'
        elsif @user.dataFiles.length >= 2
            result_json[:msg] = 'You have exceeded the maximum number of files!'
        elsif params[:dataFiles][0].size > maxSize
            result_json[:msg] = `You have exceeded the maximum size of the file(#{maxSize})!`
        else
            canBeSave = true
            @user.dataFiles = params[:dataFiles]
        end
        # Rails.logger.debug "canbesave is #{canBeSave}"
        if @user.save && canBeSave
            result_json[:code] = true
            result_json[:msg] = 'Done!'
        end
        render json: result_json
    end

    def data_file_attach
        level = Hash[
            'EMERG'     => 0,   'ALERT'     => 1,   'CRIT'      => 2,
            'ERR'       => 3,   'WARNING'   => 4,   'NOTICE'    => 5,
            'INFO'      => 6,   'DEBUG'     => 7,   'NONE'      => 8,
        ]
        status = level['EMERG']
        user = 1
        begin
            # Get the target user and check current file count
            if params[:id].nil?
                status = level['ERR']
                raise 'Cannot locate user profile!'
            end
            user = User.find(params[:id])
            if user.dataFiles.length >= 2
                status = level['NOTICE']
                raise 'You have exceeded the maximum number of files!'
            end

            # Server path settings
            dirname = '/disk2/workspace/platform/gapp/upload/'
            extension = '.fq.gz'
            mimetype = 'application/x-gzip'
            switch = 'Pool_Status.open'

            # Check input parameter for path
            if params[:path].nil? || params[:path] == ''
                status = level['WARNING']
                raise 'No file path received!'
            end
            filename = params[:path]

            # For security reasons, server status checking
            indicator = dirname + switch
            unless File.exist?(indicator)
                status = level['ERR']
                raise 'Server not available'
            end

            # For security reasons, check original file path - Part I
            basename = filename + extension
            pathname = dirname + basename
            unless File.exist?(pathname)
                status = level['NOTICE']
                raise 'Cannot find your file, please double check!'
            end

            # For security reasons, compose secure file path - Part II
            s_filename = File.basename(pathname, extension)
            s_basename = s_filename + extension
            s_pathname = dirname + s_basename
            unless File.exist?(s_pathname)
                status = level['ALERT']
                raise 'Potential LFI attacks or illegal file reading!'
            end

            # Core file attach operation
            user.dataFiles.attach(io: File.open(s_pathname), filename: s_basename, content_type: mimetype)

            # Save and judge
            if user.save
                flash[:notice] = 'Done!'
            end
        rescue StandardError => e
            if status <= level['ERR']
                flash[:error] = e.message
            else
                flash[:alert] = e.message
            end
        end
        redirect_to user_path(user)
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
                uploadTime: f.created_at.localtime.to_s.split[0]
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
        @user.dataFiles.find(params[:dataId]).purge
         result_json[:code] = true
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
            @user = User.find_by(account_id: current_account.id)
        end

        def user_params
            params.require(:user).permit(:username, :password_digest, dataFiles:[])
        end

end
