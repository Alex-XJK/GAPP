class AppsController < ApplicationController
  def index
    @apps = App.all
  end

  def show
    @app = App.find(params[:id])
  end

  def new
    @app = App.new
  end

  def create
    @app = App.new(app_params)

    if @app.save
      redirect_to @app
    else
      render :new
    end
  end

  def edit
    @app = App.find(params[:id])
  end

  def update
    @app = App.find(params[:id])

    if @app.update(app_params)
      redirect_to @app
    else
      render :edit
    end
  end

  def destroy
    @app = App.find(params[:id])
    @app.destroy

    redirect_to apps_path
  end

  private
    def app_params
      params.require(:app).permit(:app_no, :name, :price, :description, :create_report, :status, :user_id, :analysis_id)
    end
end
