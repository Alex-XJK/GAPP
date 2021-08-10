class AppsController < ApplicationController
  http_basic_authenticate_with name: "gappdev", password: "hyqxjkzx", only: [:upgrade, :update, :destroy]

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
    @analysis = Analysis.all.collect { |item| [item.name, item.id] }
    @category = Category.all.order(:name).collect { |item| [item.name, item.id] }
    if params[:uid]
      @user = params[:uid]
    else
      redirect_to apps_path
    end
  end

  def create
    @app = App.new(app_params)

    if @app.category_id.nil?
      flash[:alert] = 'Category not found!'
      redirect_to createnew_app_path(@app.user_id)
      return
    end
    cate = Category.find(@app.category_id)

    appnostr = "%s-%.6d" % [cate.initial, cate.serial]
    @app.update(app_no: appnostr)

    if @app.save
      newnum = cate.serial + 1
      cate.update(serial: newnum)
      redirect_to apps_path
    else
      flash[:alert] = 'Save failed! Please check again!'
      redirect_to createnew_app_path(@app.user_id)
    end
  end

  def edit
    @app = App.find(params[:id])
    @analysis = Analysis.all.collect { |item| [item.name, item.id]}.insert(0, ['Please select...', nil])
    @user = @app.user_id
  end

  def update
    @app = App.find(params[:id])

    if @app.update(app_params)
      redirect_to apps_path
    else
      render :edit
    end
  end

  def destroy
    @app = App.find(params[:id])
    @app.destroy

    redirect_to apps_path
  end

  def apps_info
    @apps = App.where(category_id: params[:cate])
    result_json = {
        code: false,
        data:[]
    }
    return_apps = []
    @apps.each do |a|
        return_apps.push({
            Id: a.id,
            name: a.name,
            cate: a.category_id
        })
    end
    result_json[:code] = true
    result_json[:data] = return_apps
    render json: result_json
end

  private
    def app_params
      params.require(:app).permit(:app_no, :name, :price, :description, :create_report, :status, :user_id, :analysis_id, :category_id, :cover_image, :panel)
    end
end
