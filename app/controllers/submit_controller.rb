class SubmitController < ApplicationController
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

  def query_app_task_dummy
    return_json_hash = {
      "status":"success",
      "message":{
         "status":"finished",
         "nodes":[
            {
               "id":671,
               "name":"meta_module_double_input_test",
               "outputs":[
                  {
                     "id":911,
                     "name":"output",
                     "desc":"output of double testing",
                     "files":[
                        {
                           "name":"test_double_output.txt",
                           "path":"/project/platform_task_test/gutmeta_pipeline_test1/task_20210517132818/DOAP_meta_module_double_input_test/3P4dmDkcKjCAJANvPLmiwj/output"
                        }
                     ]
                  }
               ]
            }
         ]
      }
   }
   
    # @task = Task.find_by! id:params[:job_id], user_id:session[:user_id]
    @task = Task.find_by! id:params[:job_id], user_id:session[:user_id]

    # Rails.logger.debug @task
    result = JSON.parse(return_json_hash.to_json)

    if @task.status === 'submitted'
      @task.status = @result['message']['status']
      @task.save!
    end

    response_body = []

    if TaskOutput.where(task_id:@task.id).exists? 
      task_outputs = TaskOutput.where(task_id:@task.id)
      task_outputs.each do |otp|
        @task_output = otp
        @analysis = otp.analysis
        parsed_output = processTaskOutput()
        response_body << parsed_output
      end
    elsif !@task.analysis.blank? # module task
      @analysis = @task.analysis
      @task_output = create_task_output(result['message'])
      parsed_output = processTaskOutput()
      response_body << parsed_output
    else
      @response_body = []
      # pipeline = AnalysisPipeline.find @task.analysis_pipeline_id
      result['message']['nodes'].each do |mrs|
        Rails.logger.debug "=====>"
        @analysis = Analysis.find_by(mid:mrs['id'])
        @task_output = create_task_output(mrs)
        parsed_output = processTaskOutput()
        response_body << parsed_output
      end
    end

    render json: response_body
  end

  def submit_app_task_dummy
    # uid = session[:user_id]
    uid = 1
    @user = User.find(uid)
    # user_dir = File.join($user_stor_dir, uid.to_s)

    result_json = {
      code: false,
      data: ''
    }
    begin
      app_id = params[:app_id]
      app_inputs = params[:inputs]
      # app_params = params[:params]
      # app_selected = params[:selected]
      # is_analysis = true
      # if !params[:mid].blank?
      #   @analysis = Analysis.find_by mid:params[:mid]
      # else
      #   is_analysis = false
      #   @pipeline = AnalysisPipeline.find_by pid:params[:pid]
      # end

      # submit task

      result_hash = {
        message: {
          code: 0,
          data: {
            task_id: 10,
            msg: 'success'
          }
        }
      }
      result = JSON.parse(result_hash.to_json)
      if result['message']['code']
        result_json[:code] = true
        @task  = @user.tasks.new
        @task.status = 'submitted'
        @task.tid = result['message']['data']['task_id']
        if is_analysis
          @task.analysis = @analysis
          @task.analysis_pipeline = nil
        else
          @task.analysis_pipeline = @pipeline
          @task.analysis = nil
        end
        @task.save!
        @user.updated_at = Time.now
        @user.save!
        result_json[:data] = {
          'msg': result['message']['data']['msg'],
          'task_id': @task.id
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
    render json: result_json
  end

  def submit_app_task

    logger.debug "In SAT :: receive request!"

    result_json = {
      code: false,
      data: ''
    }
    begin
      app_id = params[:app_id]
      app_inputs = params[:inputs]
      app_params = params[:params]

      logger.debug "In SAT :: param get!"

      inputs = Array.new
      params = Array.new

      logger.debug "In SAT :: created var!"

      # store input file to user's data folder
      app_inputs&.each do |k, v|
        uploader = JobInputUploader.new
        uploader.store!(v)
        inputs.push({
                      k => '/data/' + v.original_filename,
                    })
        logger.debug "In SAT :: app_inputs :: file #{k} ==> #{v.original_filename} done !"
      end

      logger.debug "In SAT :: files finished processing!"

      app_params&.each do |p|
        p.each do |k, v|
          params.push({
                        k => v,
                      })
        end
      end

      logger.debug "In SAT :: app_params finished processing!"
      logger.debug "In SAT :: pre-submit!"

      # submit task
      client = LocalApi::Client.new
      result = client.run_module(UID, PROJECT_ID, app_id.to_i, inputs, params)

      logger.debug "In SAT :: after submit get result #{result} !"

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

    logger.debug "In SAT :: now every thing done #{result_json[:data]} !"

    render json: result_json
  end

  def query_app_task
    result_json = {
      code: false,
      data: ''
    }
    begin
      @task = Task.find_by! id:params[:job_id], user_id:session[:user_id]
      
      if TaskOutput.where(task_id:@task.id).exists?
        response_body = []
        task_outputs = TaskOutput.where(task_id:@task.id)
        task_outputs.each do |otp|
          @task_output = otp
          @analysis = otp.analysis
          parsed_output = processTaskOutput()
          response_body << parsed_output
        end
        render json: response_body
        return
      end
      # query task
      client = LocalApi::Client.new
      result = ''
      if !@task.analysis.blank?
        result = client.task_info(UID, @task.tid, 'app')
      else
        result = client.task_info(UID, @task.tid, 'pipeline')
      end
      Rails.logger.info(result)

      if @task.status == 'submitted'
        @task.status = result['message']['status']
        @task.save!
      end


      if result['status'] == 'success'
        response_body = []

        @task_output = {}
        
        if result['message']['status'] == 'finished'
          if !@task.analysis.blank? # module task
            @analysis = @task.analysis
            @task_output = create_task_output(result['message'])
            parsed_output = processTaskOutput()
            response_body << parsed_output
          else
            @response_body = []
            # pipeline = AnalysisPipeline.find @task.analysis_pipeline_id
            result['message']['nodes'].each do |mrs|
              @analysis = Analysis.find_by(mid:mrs['id'])
              @task_output = create_task_output(mrs)
              parsed_output = processTaskOutput()
              response_body << parsed_output
            end
          end
        end
        render json: response_body
        return
        result_json[:data] = {
          'msg': "the task is #{result['message']['status']}",
        }
      else
        result_json[:data] = result['message']
      end
     
    rescue StandardError => e
      result_json[:code] = false
      result_json[:data] = e.message
    end
    render json: result_json
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
