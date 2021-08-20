class SubmitController < ApplicationController
  http_basic_authenticate_with name: "gappdev", password: "hyqxjkzx", only: [:index, :submit_task_debug, :submit_task_traditional, :query_task_debug]

  UID = 45
  PROJECT_ID = 289
  # $user_stor_dir = "#{Rails.root}/data/user"
  def analyses
    @analyses = Analysis.where "mid is not null"
  end

  def pipelines
    @pipelines = AnalysisPipeline.all
  end
  
  def query_app_task_test
    result_json = {
      code: false,
      data: ''
    }
    begin
      # @task = Task.find_by! id:params[:job_id], user_id:session[:user_id]
      
      # submit task
      client = LocalApi::Client.new
      # result = client.task_info(UID, 235, 'app')
      # Rails.logger.info result
      result = client.task_info(UID, 235, 'pipeline')
      Rails.logger.info result
      @result_message = result
      # result_json[:data] = result
    rescue StandardError => e
      result_json[:code] = false
      result_json[:data] = e.message
    end
    # render json: result_json
  end

  def index
    id = params[:id]
    gon.push id: id
    # uid = session[:user_id]
    # @user = User.find(uid)
    # # user_dir = File.join($user_stor_dir, uid.to_s)
    # @datasets = @user.datasets
    # data = {}
    # @datasets.each do |ds|
    #   ds_name = ds.name
    #   # ds_dir = File.join(user_dir, ds_name)
    #   # file_list = Dir.entries(ds_dir)[2..-1]
    #   data[ds_name] = ds_name
    # end
    # gon.push select_box_option: data

  end

  def query
    id = params[:id]
    uid = session[:user_id]
    @user = User.find(uid)
    # user_dir = File.join($user_stor_dir, @user.id.to_s)
    if @user.task_ids
      @task_list = @user.task_ids.split(',')
    else
      @task_list = []
    end
    gon.push tasks: @task_list
  end

  def pipeline
    id = params[:id]
    gon.push id: id
    uid = session[:user_id]
    @user = User.find(uid)
    # user_dir = File.join($user_stor_dir, uid.to_s)
    @datasets = @user.datasets
    data = {}
    @datasets.each do |ds|
      ds_name = ds.name
      # ds_dir = File.join(user_dir, ds_name)
      # file_list = Dir.entries(ds_dir)[2..-1]
      data[ds_name] = ds_name
    end
    gon.push select_box_option: data
  end

  def query_all # query all tasks by user
    @tasks = Task.where("user_id = ?", session[:user_id])
    parsed_jobs = []
    @tasks.each do |t|
      # submit task
      if t.status == 'running' || t.status == "submitted"
        client = LocalApi::Client.new
        result = client.task_info(UID, t.tid, 'app')
        Rails.logger.debug "===>#{result}"
        if result['status'] == 'success'
          t.status = result['message']['status']
          t.save!
        end
      end
      if !t.analysis.blank?
        Rails.logger.debug t.analysis
        jobName = t.analysis.name
      else
        Rails.logger.debug t.analysis_pipeline
        jobName = t.analysis_pipeline.name
      end
      parsed_jobs.push({
        jobName: jobName,
        jobId: t.id,
        created: t.created_at,
        status: t.status,
      })
    end
    render json:parsed_jobs
  end

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
      result = client.run_module(UID, PROJECT_ID, @anaid, @inputs, params)

      logger.debug "In STD :: after submit get result #{result} !"

      if result['message']['code']
        @result_json[:code] = true
        @result_json[:data] = {
          'msg': result['message']['data']['msg'],
          'task_id': encode(result['message']['data']['task_id'])
        }
      else
        @result_json[:code] = false
        @result_json[:data] = {
          'msg': result['message']
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
      task_param = params[:tid]
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
  def process_module_result
  
  end

  # TODO 写好看点
  def create_task_output(mrs)
    #   {
    #     "id":671,
    #     "name":"meta_module_double_input_test",
    #     "outputs":[
    #        {
    #           "id":911,
    #           "name":"ojutput",
    #           "desc":"output of double testing",
    #           "files":[
    #              {
    #                 "name":"test_double_output.txt",
    #                 "path":"/project/platform_task_test/gutmeta_pipeline_test1/task_20210517132818/DOAP_meta_module_double_input_test/3P4dmDkcKjCAJANvPLmiwj/output"
    #              }
    #           ]
    #        }
    #     ]
    #  }
    # @task, @analysis
    
    task_output = @task.task_outputs.new
    task_output.analysis = @analysis
    file_paths = {}
    files_to_do = mrs['outputs'][0]['files']
    
    @analysis.files_info.each do |dataType, info|
      @viz_data_source = VizDataSource.find_by(data_type:dataType)
      if @viz_data_source.allow_multiple
        files_to_do.each do |of1|
          info['outputFileName'].each do |fName|
            if matchPattern(of1['name'], fName)
              file_paths[dataType] = [] if file_paths[dataType].blank?
              file_paths[dataType] << {id: 0, 
                                      url: File.join('/data/outputs', of1['path'], of1['name']), 
                                      is_demo: true}
              files_to_do.delete(of1)
            end
          end
        end
      else
        files_to_do.each do |of1|
          if of1['name'] == info['outputFileName']
            file_paths[dataType] = {id: 0, 
                                    url: File.join('/data/outputs', of1['path'], of1['name']), 
                                    is_demo: true}
            files_to_do.delete(of1)
          end
        end
      end
    end

    task_output.file_paths = file_paths
    task_output.save!
    return task_output
  end

  def processTaskOutput
    @analysis_user_datum = AnalysisUserDatum.findOrInitializeBy @analysis.id, session[:user_id]
    @analysis_user_datum.task_output = @task_output
    @analysis_user_datum.use_demo_file = false
    @analysis_user_datum.save!
    parsed_output = {}
    parsed_output['module_name'] = @analysis.visualizer.js_module_name
    parsed_output['name'] = @analysis.name
    parsed_output['analysis_id'] = @analysis.id
    parsed_output['required_data'] = @analysis.files_info.keys
    return parsed_output
  end

  def remove_task
    @task = Task.find params[:job_id]
    @analysis_user_datum = AnalysisUserDatum.find_by task_output: @task.task_outputs[0]
    @analysis_user_datum.task_output = nil
    @analysis_user_datum.use_demo_file = true
    @analysis_user_datum.save!
    @task.destroy!
    render json:{code:true}
  end

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
end
