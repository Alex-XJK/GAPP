class Users::TasksController < ApplicationController
    before_action :set_task, only: [:show, :edit, :update, :destroy]

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.all
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
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
    @task.usedData = params[:checkedData]
    @task.status = 0
    @task.created_at = Time.now
    @task.updated_at = Time.now
    if @task.save
      result_json[:code] = true
      render json: result_json
    else
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
          return_tasks.push({
            id: t.id,
            name: t.name,
            status: t.status,
            app_id: t.app_id
          })
        end
      end
    end
    result_json[:code] = true
    result_json[:data] = return_tasks
    render json: result_json
  end

  def task_page
    respond_to do |format|
      format.html { redirect_to :controller => 'tasks',:action=>'show' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:name, :status, :app_id, :user_id)
    end
end
