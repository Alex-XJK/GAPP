class TasksController < ApplicationController
    before_action :set_task, only: [:show, :edit, :update, :destroy]
    http_basic_authenticate_with name: "gappdev", password: "hyqxjkzx", only: [:submit_task_debug, :query_task_debug]

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.all
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    gon.push(task_id: @task.id)
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new
    result_json = {
      code: false
    }
    @task.name = params[:taskName]
    @task.app_id = params[:app_id]
    @task.user_id = params[:user_id]
    @task.task_id = params[:task_id]
    @task.usedData = params[:checkedData]
    @task.status = 'running'
    @task.created_at = Time.now
    @task.updated_at = Time.now
    if @task.save
      result_json[:code] = true
      flash[:success] = "Task successfully created"
      render json: result_json
    else
      flash[:error] = "Fail to create a task"
      format.html { render :new }
      format.json { render json: @task.errors, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def tasks_info
    # Query and update all task inside the db
    query_all_task()
    result_json = {
            code: false,
            data:[]
        }
    apps = params[:apps]
    user_id = params[:id]
    return_tasks = []
    if apps != nil
      apps.each do |a|
        app_id = a["Id"]
        @tasks = Task.where(app_id: app_id, user_id: user_id)
        # Rails.logger.debug("here i am! #{@tasks.length}")
        @tasks.each do |t|
          # Rails.logger.debug("here i am again!")
          t_status = 0
          barType = ''
          if t.status == 'running'
            t_status = 60
          elsif t.status == 'finished'
            t_status = 100
            barType = 'success'
          else
            t_status = 40
            barType = 'exception'
          end
          return_tasks.push({
            id: t.id,
            name: t.name,
            status: t_status,
            app_id: t.app_id,
            barType: barType
          })
        end
      end
    end
    result_json[:code] = true
    result_json[:data] = return_tasks
    # Rails.logger.debug(return_tasks)
    render json: result_json
  end

  def task_page
    @task = Task.find(params[:taskId])
    redirect_to action:"show", controller:"tasks", user_id:@task.user_id, id: @task.id
    # render json: result
  end

  # def task_status
  #   result_json = {
  #     code: false,
  #     data:[]
  #   }
  #   @task = Task.find(params[:task_id])
  #   return_status = @task.status
  #   result_json[:code] = true
  #   result_json[:data] = return_status
  #   render json: result_json
  # end


  UID = 45
  PROJECT_ID = 289
  # $user_stor_dir = "#{Rails.root}/data/user"

  def submit_task
    # init
    result_json = {
      code: false,
      data: ''
    }
    begin

      # Receive and find the User Data File
      id = params[:uid]
      idx = params[:fid]
      user = User.find(id)
      # file = user.dataFiles.find(idx)
      file = user.dataFiles[idx.to_i]
      floc = ActiveStorage::Blob.service.send(:path_for, file.blob.key)
      fnam = file.filename.to_s

      # Receive and find the App Panel File
      aid = params[:app]
      app = App.find(aid)
      panl = app.panel
      ploc = ActiveStorage::Blob.service.send(:path_for, panl.blob.key)
      pnam = panl.filename.to_s

      # The hard code area, used to set the location path
      datafn = 'i-1004'
      panefn = 'i-1005'
      tarloc = '/home/platform/omics_rails/current/media/user/meta_platform/data/'

      # Create the string of filename
      file_new_location = tarloc + fnam
      panel_new_location = tarloc + pnam

      # Copy the files to the target place and rename them to the system accepted one
      system "cp #{floc} #{file_new_location}"
      system "cp #{ploc} #{panel_new_location}"

      # Prepare the API parameters
      anaid = Analysis.find(app.analysis_id).doap_id.to_i
      logger.debug "In SuT :: #{anaid} >>"

      inputs = Array.new
      inputs.push({ datafn => '/data/' + fnam, })
      # inputs.push({ panefn => '/data/' + pnam, })
      logger.debug "In SuT :: #{inputs} >>"

      params = Array.new
      logger.debug "In SuT :: #{params} >>"

      # Submit task
      client = LocalApi::Client.new
      result = client.run_module(UID, PROJECT_ID, anaid, inputs, params)

      logger.debug "In SuT :: after submit get result #{result} !"

      # Interpret and encode the result
      if result['message']['code']
        result_json[:code] = true
        result_json[:data] = {
          'msg': result['message']['data']['msg'],
          'task_id': encode(result['message']['data']['task_id'])
        }
      else
        result_json[:code] = false
        result_json[:data] = {
          'msg': result['message']
        }
      end
    rescue StandardError => e
      result_json[:code] = false
      result_json[:data] = e.message
    end
    logger.debug "In SuT :: now every thing done with JSON: #{result_json} !"
    render json: result_json
  end

  def submit_task_debug
    # init
    @result_json = {
      code: false,
      data: ''
    }
    begin

      # Display the Rails root for debug
      @rrot = Rails.root.to_s

      # Receive and find the User Data File
      id = params[:uid]
      idx = params[:fid]
      user = User.find(id)
      file = user.dataFiles[idx.to_i]
      @floc = ActiveStorage::Blob.service.send(:path_for, file.blob.key)
      @fnam = file.filename.to_s

      # Receive and find the App Panel File
      aid = params[:app]
      app = App.find(aid)
      panl = app.panel
      @ploc = ActiveStorage::Blob.service.send(:path_for, panl.blob.key)
      @pnam = panl.filename.to_s

      # The hard code area, used to set the location path
      datafn = 'i-1004'
      panefn = 'i-1005'
      # tarloc = '/Users/jiakaixu2/Desktop/RA-GAPP/gapp_rails/tmp/'
      tarloc = '/home/platform/omics_rails/current/media/user/meta_platform/data/'

      # Create the string of filename
      @file_new_location = tarloc + @fnam
      @panel_new_location = tarloc + @pnam

      # Copy the files to the target place and rename them to the system accepted one
      system "cp #{@floc} #{@file_new_location}"
      system "cp #{@ploc} #{@panel_new_location}"

      # Prepare the API parameters (redirect to stdout for debug now)
      @anaid = Analysis.find(app.analysis_id).doap_id.to_i
      logger.debug "In STD :: #{@anaid} >>"
      @inputs = Array.new
      @inputs.push({ datafn => '/data/' + @fnam, })
      # @inputs.push({ panefn => '/data/' + @pnam, })
      logger.debug "In STD :: #{@inputs} >>"
      params = Array.new
      logger.debug "In STD :: #{params} >>"

      # Already existing code
      # submit task
      client = LocalApi::Client.new
      @result = client.run_module(UID, PROJECT_ID, @anaid, @inputs, params)

      logger.debug "In STD :: after submit get result #{@result} !"

      if @result['message']['code']
        @result_json[:code] = true
        @result_json[:data] = {
          'msg': @result['message']['data']['msg'],
          'task_id': encode(@result['message']['data']['task_id'])
        }
      else
        @result_json[:code] = false
        @result_json[:data] = {
          'msg': @result['message']
        }
      end
    rescue StandardError => e
      @result_json[:code] = false
      @result_json[:data] = e.message
    end

    logger.debug "In STD :: now every thing done with JSON: #{@result_json} !"
  end

  def submit_task_traditional

    result_json = {
      code: false,
      data: ''
    }
    begin
      app_id = params[:app_id]
      app_inputs = params[:inputs]
      app_params = params[:params]

      inputs = Array.new
      params = Array.new

      # store input file to user's data folder
      app_inputs&.each do |k, v|
        uploader = JobInputUploader.new
        uploader.store!(v)
        inputs.push({
                      k => '/data/' + v.original_filename,
                    })
        logger.debug "In STT :: app_inputs :: file #{k} ==> #{v.original_filename} done !"
      end

      app_params&.each do |p|
        p.each do |k, v|
          params.push({
                        k => v,
                      })
          logger.debug "In STT :: app_params :: param #{k} ==> #{v} done !"
        end
      end

      logger.debug 'In STT :: ready to submit!'

      # submit task
      client = LocalApi::Client.new
      result = client.run_module(UID, PROJECT_ID, app_id.to_i, inputs, params)

      logger.debug "In STT :: after submit get result #{result} !"

      if result['message']['code']
        result_json[:code] = true
        result_json[:data] = {
          'msg': result['message']['data']['msg'],
          'task_id': encode(result['message']['data']['task_id'])
        }
      else
        result_json[:code] = false
        result_json[:data] = {
          'msg': result['message']
        }
      end
    rescue StandardError => e
      result_json[:code] = false
      result_json[:data] = e.message
    end

    logger.debug "In STT :: now every thing done with JSON: #{result_json} !"

    render json: result_json
  end

  def query_task
    result_json = {
      code: false,
      data: ''
    }
    begin

      # Receive and decode task id
      @task = Task.find(params[:id])
      task_param = @task.task_id
      # task_param = params[:tid]
      task_id = decode(task_param)

      if task_id
        # Query task
        client = LocalApi::Client.new
        result = client.task_info(UID, task_id, 'app')

        logger.debug "In QuT :: after query get result #{result} !"

        # Interpret result
        result_json[:code] = result['status']
        result_json[:data] = result['message']
      else
        result_json[:code] = true
        result_json[:data] = {
          'msg': 'Task not found!',
          'task_id': task_param
        }
      end
    rescue StandardError => e
      result_json[:code] = false
      result_json[:data] = e.message
    end
    logger.debug "In QuT :: now every thing done with JSON: #{result_json} !"
    render json: result_json
  end

  def query_task_status
    result_json = {
      status: ''
    }
    begin

      # Receive and decode task id
      task_param = params[:tid]
      task_id = decode(task_param)

      if task_id
        # Query task
        client = LocalApi::Client.new
        result = client.task_info(UID, task_id, 'app')

        logger.debug "In QTs :: after query get result #{result} !"

        # Interpret result
        result_json[:status] = result['message']['status']
      else
        result_json[:status] = 'Task not found!'
      end
    rescue StandardError => e
      result_json[:status] = e.message
    end
    logger.debug "In QTs :: now every thing done with JSON: #{result_json} !"
    render json: result_json
  end

  def query_task_debug
    @result_json = {
      code: false,
      data: ''
    }
    begin
      # Display the Rails root for debug
      @rrot = Rails.root.to_s

      # Receive and decode task id
      @task_param = params[:tid]
      @task_id = decode(@task_param)

      if @task_id
        # Query task
        client = LocalApi::Client.new
        @result = client.task_info(UID, @task_id, 'app')

        logger.debug "In QTD :: after query get result #{@result} !"

        # Interpret result
        @result_json[:code] = @result['status']
        @result_json[:data] = @result['message']
      else
        @result_json[:code] = true
        @result_json[:data] = {
          'msg': 'Task not found!',
          'task_id': @task_param
        }
      end
    rescue StandardError => e
      @result_json[:code] = false
      @result_json[:data] = e.message
    end
    # render json: result_json
    logger.debug "In QTD :: now every thing done with JSON: #{@result_json} !"
  end

  private

  def encode(id)
    hashids = Hashids.new("this is my salt", 16)
    hashids.encode(id)
  end
  def decode(id)
    hashids = Hashids.new("this is my salt", 16)
    hashids.decode(id)[0]
  end

  def matchPattern(name, pattern)
    if pattern.include? "*"
      p = pattern.split "*"
      p.each do |x|
        return false if !name.include? x
      end
      return true
    else 
      return pattern == name
    end
  end

  # Query and update all task inside the db
  def query_all_task()
    Rails.logger.debug("at query all tasks")
    tasks = Task.all
    tasks.each do |ta|
      # If task already finished, then no need to check again
      orista = ta.status
      if orista == 'finished' || orista ==' failed'
        next
      end
  
      # Decode the task id first
      taskID = decode(ta.task_id)

      # Query task
      if taskID
        client = LocalApi::Client.new
        result = client.task_info(UID, taskID, 'app')
  
        logger.debug "In QAT :: query #{taskID} then get result #{result} !"
  
        # Interpret result
        if result['status'] == 'success'
          statusStr = result['message']['status']
        else
          # Failed to query the task information
          statusStr = 'Error_query_task'
        end
      else
        # Task id cannot be decoded successfully
        statusStr = 'Error_decode_id'
      end

      # Write to DB
      ta.update(status: statusStr)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def task_params
    params.require(:task).permit(:name, :status, :app_id, :user_id)
  end
end
