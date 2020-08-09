class SubmitController < ApplicationController
  UID = 39
  PROJECT_ID = 259
  TASK_ID = 1371
  def index
    id = params[:id]
    gon.push id: id
  end

  def query
  end

  def submit_app_task
    result_json = {
      code: false,
      data: ''
    }
    # begin
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
    end
    app_params&.each do |p|
      p.each do |k, v|
        params.push({
          k => v,
        })
      end
    end
    # submit task
    print("zenmehuishi~~~~~~~~~~~~")
    client = LocalApi::Client.new
    result = client.run_module(UID, PROJECT_ID, app_id, inputs, params)
    print(result)
    if result['message']['code']
      result_json[:code] = true
      result_json[:data] = {
        'msg': result['message']['data']['msg'],
        'task_id': encode(result['message']['data']['task_id'])
      }
    else
      result_json[:code] = false
      result_json[:data] = {
        'msg': result['message']['data']['msg']
      }
    end
    # rescue StandardError => e
    #   result_json[:code] = false
    #   result_json[:data] = e.message
    # end
    render json: result_json
  end


  def encode(id)
    hashids = Hashids.new("this is my salt", 16)
    hashids.encode(id)
  end
  def decode(id)
    hashids = Hashids.new("this is my salt", 16)
    hashids.decode(id)[0]
  end
end
