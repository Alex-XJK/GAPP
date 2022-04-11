class TasksController < ApplicationController
    before_action :set_task, only: [:show, :edit, :update, :destroy]
    # http_basic_authenticate_with name: "gappdev", password: "hyqxjkzx", only: [:submit_task_debug, :query_task_debug]
    before_action :authenticate_account!

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.all
  end

  def check_user
    if account_signed_in?
      if String(params[:user_id]) != String(User.find_by(account_id: current_account.id).id)
          flash[:error] = "You should not visit other's profile page. Redirect to your own page"
          redirect_to user_path(current_account.id)
      end
    else
        flash[:error] = 'You should login first'
        redirect_to root_path
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    check_user()
    gon.push(task_id: @task.id)
    if @task.status == 'finished'
      
      # The default page link
      error_link = "#"
      error_link_html = "https://gapp.deepomics.org/result/newexps/output/child/html/P2021020001.html"

      # Query result from server
      client = LocalApi::Client.new
      task_id = decode(@task.task_id)
      result = client.task_info(UID, task_id,'app')
      Rails.logger.info("TaskShow >> Query: rails [#{@task.id}], deepomics [#{@task.task_id}]")
      Rails.logger.info(result)
      Rails.logger.info("#{result}")

      begin
        # Nil result checking
        if result == nil
          raise 'TaskShow >> Cannot perform API query, Nil result'
        end

        # Not success query checking
        if result['status'] != 'success'
          status_msg = result['status']
          raise "TaskShow >> Bad API query, [status]: #{status_msg}"
        end

        # Prepare project download
        rrot = Rails.root.to_s
        if result['message']["outputs"].length() == 0
          raise "TaskShow >> Error: Output Length is ZERO!"
        end
        if result['message']["outputs"][0]["files"].length() == 0
          raise "TaskShow >> Error: The first output file Length is ZERO!"
        end
        server_path = result['message']["outputs"][0]["files"][0]["path"]
        server_id = server_path.split("task_")[1].split("/user")[0]
        rails_path = rrot + "/public/result/task_" + server_id
        system "mkdir #{rails_path}"

        # Download raw data
        data_server_path = "/home/platform/omics_rails/current/media/user/gapp" + server_path + "/data.raw.vcf.gz"
        @data_download_path = "/result/task_" + server_id + "/data.raw.vcf.gz"
        unless File.exist?(data_server_path)
          raise "TaskShow >> Raw Data does not exist at #{data_server_path}"
        end
        system "ln -s #{data_server_path} #{rails_path}"

        # # Download PDF report
        # # Server PDF Processing...
        # pdf_server_path = ""
        @pdf_download_path = "/result/task_" + server_id
        # unless File.exist?(pdf_server_path)
        #   raise "TaskShow >> Report PDF does not exist at #{pdf_server_path}"
        # end

        # # Access HTML page
        # # Server HTML Processing...
        # html_server_path = ""
        @html_download_path = "/result/task_" + server_id + "/report/output/child/html/P2021020001.html"
        # unless File.exist?(html_server_path)
        #   raise "TaskShow >> Report HTML does not exist at #{html_server_path}"
        # end

      rescue StandardError => e
        Rails.logger.error("#{e.message}")
        @data_download_path = error_link
        @pdf_download_path = error_link
        @html_download_path = error_link_html
      end
    end
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
    @app = App.find(params[:app_id])
    @task = Task.new
    result_json = {
      code: false
    }
    @task.name = params[:taskName]
    @task.app_id = params[:app_id]
    @task.user_id = params[:user_id]
    @task.task_id = params[:task_id]
    # @task.usedData = params[:checkedData]
    @task.status = 'running'
    @task.generate_report = @app.create_report
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
  Rails.logger.debug("apps! #{params[:apps]}")
  Rails.logger.debug("user_id! #{params[:id]}")
    return_tasks = []
    if apps != nil
      apps.each do |a|
        app_id = a["Id"]
        @tasks = Task.where(app_id: app_id, user_id: user_id)
        Rails.logger.debug("here i am! #{@tasks.length}")
        @tasks.each do |t|
          Rails.logger.debug("here is a #{a}")
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

  # Used for GAPP only!
  UID = 50
  # Used for our GAPP_TEST project only!
  PROJECT_ID = 344

  # @api Our Core Task Submission API, please be careful when you edit this part,
  #     and only on-the-server debugging is valid, no local testing for this function.
  # @author Contact Mr. Jiakai XU for details (for further development only)
  def submit_task
    # init
    result_json = {
      code: false,
      data: ''
    }
    begin

      # Receive parameters from fronten-end
      id = params[:uid]
      idx = params[:fid]
      aid = params[:app]

      # Judge whether selected TWO files for *_1.fq.gz and *_2.fq.gz datafile
      if idx.length < 2
        raise "The selected user data files number less than 2, which does not meet the analysis requirement!"
      end

      # Find the User Data Files
      user = User.find(id)
      file1 = user.dataFiles.find(idx[0])
      file2 = user.dataFiles.find(idx[1])
      floc1 = ActiveStorage::Blob.service.send(:path_for, file1.blob.key)
      floc2 = ActiveStorage::Blob.service.send(:path_for, file2.blob.key)

      # Set system variables
      userid = id.to_s
      timestamp = Time.now.to_i.to_s
      disk_user = "/disk2/workspace/platform/gapp/user#{userid}"
      disk_data = "#{disk_user}/data/"
      file1_new_location = disk_data + timestamp + '_1.fq.gz'
      file2_new_location = disk_data + timestamp + '_2.fq.gz'

      # Copy the files to the target place and rename them to the system accepted one
      system "mkdir #{disk_user}"
      system "mkdir #{disk_data}"
      system "cp #{floc1} #{file1_new_location}"
      system "cp #{floc2} #{file2_new_location}"

      # Find the App Panel File
      app = App.find(aid)
      if app.panel.attached?
        panl = app.panel
        ploc = ActiveStorage::Blob.service.send(:path_for, panl.blob.key)
        panel_new_location = disk_data + timestamp + '_panel.txt'
        system "cp #{ploc} #{panel_new_location}"
      end

      # Prepare the API parameters
      anaid = Analysis.find(app.analysis_id).doap_id.to_i
      logger.debug "In SuT :: #{anaid} >>"

      p4uid = Analysis.find(app.analysis_id).param_for_userid.to_s
      p4fid = Analysis.find(app.analysis_id).param_for_filename.to_s

      # Generate Json
      jsonkey = "u" + userid + "f" + timestamp
      generate_json(user.id, current_account.id, timestamp, app.id, jsonkey)

      # Build the file input dictionary
      inputs = Array.new
      logger.debug "In SuT :: #{inputs} >>"

      # Build the parameter input dictionary
      params = Array.new
      params.push({ p4uid => userid, })
      params.push({ p4fid => timestamp, })
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
      edroot = @rrot.split('releases')[0]
      @uproot = edroot + 'releases/shared'

      # Receive and find the User Data File
      id = params[:uid]
      idx = params[:fid]
      user = User.find(id)
      file = user.dataFiles.find(idx)
      # file = user.dataFiles[idx.to_i]
      @floc = ActiveStorage::Blob.service.send(:path_for, file.blob.key)
      @fnam = file.filename.to_s

      # Receive and find the App Panel File
      aid = params[:app]
      app = App.find(aid)
      panl = app.panel
      @ploc = ActiveStorage::Blob.service.send(:path_for, panl.blob.key)
      @pnam = panl.filename.to_s

      # New version here >>>
      userid = id.to_s
      diskuser = "/disk2/workspace/platform/gapp/user#{userid}"
      disk = "#{diskuser}/data/"
      timestamp = Time.now.to_i.to_s
      @file1_new_location = disk + timestamp + '_1.fq.gz'
      @file2_new_location = disk + timestamp + '_2.fq.gz'
      # Copy the files to the target place and rename them to the system accepted one
      system "mkdir #{diskuser}"
      system "mkdir #{disk}"
      system "cp #{@floc} #{@file1_new_location}"
      system "cp #{@ploc} #{@file2_new_location}"

      # Prepare the API parameters (redirect to stdout for debug now)
      @anaid = Analysis.find(app.analysis_id).doap_id.to_i
      logger.debug "In STD :: #{@anaid} >>"
      @inputs = Array.new
      logger.debug "In STD :: #{@inputs} >>"
      @params = Array.new
      p4uid = Analysis.find(app.analysis_id).param_for_userid.to_s
      p4fid = Analysis.find(app.analysis_id).param_for_filename.to_s
      @params.push({ p4uid => userid, })
      @params.push({ p4fid => timestamp, })
      logger.debug "In STD :: #{@params} >>"

      # # Optimize disk storage
      # @optf = @floc.to_s.gsub(@uproot, '/data')
      # @optp = @ploc.to_s.gsub(@uproot, '/data')
      #
      # # The hard code area, used to set the location path
      # datafn = 'i-1004'
      # panefn = 'i-1005'
      # tarloc = '/home/platform/omics_rails/current/media/user/meta_platform/data/'
      #
      # # Create the string of filename
      # @file_new_location = tarloc + @fnam + '(NO_NEED_ANY_MORE)'
      # @panel_new_location = tarloc + @pnam + '(NO_NEED_ANY_MORE)'

      # # Copy the files to the target place and rename them to the system accepted one
      # system "cp #{@floc} #{@file_new_location}"
      # system "cp #{@ploc} #{@panel_new_location}"

      # # Prepare the API parameters (redirect to stdout for debug now)
      # @anaid = Analysis.find(app.analysis_id).doap_id.to_i
      # logger.debug "In STD :: #{@anaid} >>"
      # @inputs = Array.new
      # # @inputs.push({ datafn => '/data/' + @fnam, })
      # @inputs.push({ datafn => @optf, })
      # # @inputs.push({ panefn => '/data/' + @pnam, })
      # # @inputs.push({ panefn => @optp, })
      # logger.debug "In STD :: #{@inputs} >>"
      # @params = Array.new
      # @params.push({ 'p-1761' => '/disk2/workspace/platform/gapp/websrl.list', })
      # @params.push({ 'p-1760' => './gapp/code', })
      # @params.push({ 'p-1758' => './gapp', })
      # logger.debug "In STD :: #{@params} >>"

      # Already existing code
      # submit task
      client = LocalApi::Client.new
      @result = client.run_module(UID, PROJECT_ID, @anaid, @inputs, @params)

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

  def submit_pipeline_debug
    # init
    @result_json = {
        code: false,
        data: ''
    }
    begin

      # Prepare the API parameters (redirect to stdout for debug now)
      @pipe_id = 62
      logger.debug "In SPD :: #{@pipe_id} >>"
      @inputs = Array.new
      in1_id = "i-146"
      in1_cn = "1"
      in2_id = "i-147"
      in2_cn = "R"
      in3_id = "i-148"
      in3_cn = Time.now.to_i.to_s
      in4_id = "i-150"
      in4_cn = "male"
      in5_id = "i-151"
      in5_cn = "TestUser"
      @inputs.push({ in1_id.to_s => in1_cn, })
      @inputs.push({ in2_id.to_s => in2_cn, })
      @inputs.push({ in3_id.to_s => in3_cn, })
      @inputs.push({ in4_id.to_s => in4_cn, })
      @inputs.push({ in5_id.to_s => in5_cn, })
      logger.debug "In SPD :: #{@inputs} >>"
      @params = Array.new
      logger.debug "In SPD :: #{@params} >>"

      # submit task
      client = LocalApi::Client.new
      @result = client.run_pipeline(UID, PROJECT_ID, @pipe_id.to_i, @inputs, @params)

      logger.debug "In SPD :: after submit get result #{@result} !"

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
    logger.debug "In SPD :: now every thing done with JSON: #{@result_json} !"
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
          'status': 'Task not found!',
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

    @path = @result_json[:data]["outputs"][0]["files"][0]["path"]
    @full_path = "/home/platform/omics_rails/current/media/user/gapp" + @path + "/data.raw.vcf.gz"
    @dir = @rrot + "/public/result/task_" + @path.split("task_")[1].split("/user")[0]
    @download_path = "/result/task_" + @path.split("task_")[1].split("/user")[0] + "/data.raw.vcf.gz"

    system "mkdir #{@dir}"
    # system "cp #{@full_path} #{@dir}"
    system "ln -s #{@full_path} #{@dir}"

  end

  def query_pipeline_debug
    @result_json = {
        code: false,
        data: ''
    }
    begin
      # Receive and decode task id
      @task_param = params[:tid]
      @task_id = decode(@task_param)

      if @task_id
        # Query task
        client = LocalApi::Client.new
        @result = client.task_info(UID, @task_id, 'pipeline')

        logger.debug "In QPD :: after query get result #{@result} !"

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
    logger.debug "In QPD :: now every thing done with JSON: #{@result_json} !"
  end

  def submit_json_debug
    # Require JSON lib
    require 'json'

    # JSON data
    uinf = {
        "name" => "alex",
        "gender" => "male",
        "age" => 21,
        "tel" => "010-123456789"
    }
    ainf = {
        "name" => "Doctor's Friend No.1",
        "id" => 100,
        "report" => true,
        "template" => true,
        "panel" => false,
        "credit" => "AHYGB9FX7W"
    }
    job_info = {
        "uid" => User.find_by(account_id: current_account.id).id,
        "fid" => Time.now.to_i.to_s,
        "user" => uinf,
        "app" => ainf
    }
    count = 0
    floc = "deepomics_job.json"
    File.open(floc,"w") do |f|
      prt_data = JSON.pretty_generate(job_info)
      count = f.write(prt_data)
    end

    # Display Part
    @rrot = Rails.root.to_s
    @dloc = @rrot+'/'+floc
    @fcount = "That was #{count} bytes of data!"

    generate_json(1, 1, "2022", 42, "test")
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
      if orista == 'finished' || orista == 'failed'
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

  def generate_json(uid, cid, fid, aid, key)
    # Require JSON lib
    require 'json'

    # Parameter Read in
    user = User.find(uid)
    account = Account.find(cid)
    app = App.find(aid)
    analysis = Analysis.find(app.analysis_id)
    file = fid.to_s
    json_location = "/home/platform/omics_rails/current/media/user/gapp/data/input_transmit/" + key.to_s + ".json"

    # Constant variable
    nif = "Not_In_File"
    credt = Digest::SHA256.hexdigest(key.to_s + "ALEX")

    # JSON data
    uinf = {
        "id"      =>  user.id,
        "name"    =>  user.username,
        "gender"  =>  nif,
        "age"     =>  nif,
        "birth"   =>  nif,
        "tel"     =>  nif,
        "email"   =>  account.email
    }
    ainf = {
        "id"        =>  app.app_no,
        "name"      =>  app.name,
        "report"    =>  app.create_report,
        "panel"     =>  app.panel.attached?,
        "template"  =>  nif,
        "operator"  =>  nif
    }
    ninf = {
        "id"          =>  analysis.doap_id,
        "name"        =>  analysis.name,
        "isPiepline"  =>  nif,
    }

    # Final Json data
    job_info = {
        "uid"       =>  user.id,
        "fid"       =>  file,
        "key"       =>  key.to_s,
        "credit"    =>  credt,
        "app"       =>  ainf,
        "user"      =>  uinf,
        "analysis"  =>  ninf
    }

    # Write to json
    count = 0
    File.open(json_location,"w") do |f|
      prt_data = JSON.pretty_generate(job_info)
      count = f.write(prt_data)
    end

    # Debug information
    Rails.logger.info("GenJson >> #{count} bytes have been write to [#{json_location}]")
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
