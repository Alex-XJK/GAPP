class AppsController < ApplicationController
  def index
    @apps = App.all
    @count_online = App.where(status: 'online').count
    @count_audit = App.where(status: 'audit').count
    @count_offline = App.where(status: 'offline').count
  end

  def show
    @app = App.find(params[:id])
    @user = User.find(@app.user_id)
    @category = Category.find(@app.category_id)
  end

  def details
    @app = App.find(params[:id])
    @user = User.find(@app.user_id)
    @analysis = Analysis.find(@app.analysis_id)
    @category = Category.find(@app.category_id)
  end

  def upgrade
    @app = App.find(params[:id])
    @app.update(status: 'online')
    redirect_to apps_path
  end

  def downgrade
    @app = App.find(params[:id])
    @app.update(status: 'offline')
    redirect_to apps_path
  end

  def new
    @app = App.new
    @analysis = Analysis.all.collect{ |item| [item.name, item.id]}.insert(0, ['Please select...', nil])
    @category = Category.all.order(:name).collect{ |item| [item.name, item.id]}.insert(0, ['Please select...', nil])
    if params[:uid]
      @user = params[:uid]
    else
      redirect_to apps_path
    end
  end

  def create
    @app = App.new(app_params)
    cate = Category.find(@app.category_id)
    appnostr = "%s-%.6d" % [cate.initial, cate.serial]
    @app.update(app_no: appnostr)
    newnum = cate.serial + 1
    cate.update(serial: newnum)

    if @app.save
      redirect_to apps_path
    else
      render :new
    end
  end

  def edit
    @app = App.find(params[:id])
    @analysis = Analysis.all.collect{ |item| [item.name, item.id]}.insert(0, ['Please select...', nil])
    @user = @app.user_id
  end

  def update
    @app = App.find(params[:id])

    if @app.update(app_params)
      redirect_to check_detail_app_path
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
      params.require(:app).permit(:app_no, :name, :price, :description, :create_report, :status, :user_id, :analysis_id, :category_id, :cover_image, :panel)
    end
end
