class AppsController < ApplicationController
  # before_action :authenticate_account!

  # http_basic_authenticate_with name: "gappdev", password: "hyqxjkzx", only: [:upgrade, :update, :destroy]

  def index
    require_producer_or_admin

    @cuser_id = User.find_by(account_id: current_account.id).id
    @user_name = User.find(@cuser_id).username
    if current_account.has_role? :admin
      @apps = App.all
    else
      @apps = App.where(user_id: @cuser_id)
    end
    @count_online = @apps.where(status: 'online').count
    @count_audit = @apps.where(status: 'audit').count
    @count_offline = @apps.where(status: 'offline').count
  end

  def show
    @app = App.find(params[:id])
    @user = User.find(@app.user_id)
    @category = Category.find(@app.category_id)

    # User and Visitor can view published apps
    # Producer can only check their own apps or other peoples' published apps
    # Admin do not have restrictions
    if account_signed_in?
      cuser_id = User.find_by(account_id: current_account.id).id
      if current_account.has_role? :producer
        unless @app.status == 'online' || @app.user_id == cuser_id
          flash[:error] = "You cannot view others unpublished APP"
          redirect_to apps_path
        end
      end
    else
      unless @app.status == 'online'
        flash[:error] = "You cannot view unpublished APP"
        redirect_to root_path
      end
    end
  end

  def details
    require_producer_or_admin

    @app = App.find(params[:id])
    @user = User.find(@app.user_id)
    @analysis = Analysis.find(@app.analysis_id)
    @category = Category.find(@app.category_id)

    # Producer can only check their own apps' details
    # Admin do not have restrictions
    cuser_id = User.find_by(account_id: current_account.id).id
    if account_signed_in? and current_account.has_role? :producer
      unless @app.user_id == cuser_id
        flash[:error] = "You cannot check APP details that are not created by you"
        redirect_to apps_path
      end
    end
  end

  def upgrade
    # Only Admin can finally publish the apps
    require_admin

    @app = App.find(params[:id])
    @app.update(status: 'online')
    redirect_to apps_path
  end

  def downgrade
    require_producer_or_admin

    @app = App.find(params[:id])
    # Producer can only operate their own apps' status
    # Admin do not have restrictions
    cuser_id = User.find_by(account_id: current_account.id).id
    if account_signed_in? and current_account.has_role? :producer
      unless @app.user_id == cuser_id
        flash[:error] = "You cannot downgrade other people's APP"
        redirect_to apps_path
      end
    end
    @app.update(status: 'offline')
    redirect_to apps_path
  end

  def new
    require_producer_or_admin

    @app = App.new
    @user = User.find_by(account_id: current_account.id).id
    @analysis = Analysis.all.collect { |item| [item.name, item.id] }
    @category = Category.all.order(:name).collect { |item| [item.name, item.id] }
  end

  def create
    require_producer_or_admin

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
    require_producer_or_admin

    @app = App.find(params[:id])
    # Producer can only edit their own apps' information
    # Admin do not have restrictions
    cuser_id = User.find_by(account_id: current_account.id).id
    if account_signed_in? and current_account.has_role? :producer
      unless @app.user_id == cuser_id
        flash[:error] = "You cannot modify other people's APP"
        redirect_to apps_path
      end
    end
    @analysis = Analysis.all.collect { |item| [item.name, item.id]}.insert(0, ['Please select...', nil])
    @user = @app.user_id
  end

  def update
    require_producer_or_admin

    @app = App.find(params[:id])
    # Producer can only edit their own apps' information
    # Admin do not have restrictions
    cuser_id = User.find_by(account_id: current_account.id).id
    if account_signed_in? and current_account.has_role? :producer
      unless @app.user_id == cuser_id
        flash[:error] = "You cannot modify other people's APP"
        redirect_to apps_path
      end
    end
    if @app.update(app_params)
      redirect_to apps_path
    else
      render :edit
    end
  end

  def destroy
    require_producer_or_admin

    @app = App.find(params[:id])
    # Producer can only delete their own apps' information
    # Admin do not have restrictions
    cuser_id = User.find_by(account_id: current_account.id).id
    if account_signed_in? and current_account.has_role? :producer
      unless @app.user_id == cuser_id
        flash[:error] = "You cannot delete other people's APP"
        redirect_to apps_path
      end
    end
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
      if a.published?
        return_apps.push({
            Id: a.id,
            name: a.name,
            cate: a.category_id
        })
      end
    end
    result_json[:code] = true
    result_json[:data] = return_apps
    render json: result_json
  end

  private

  def app_params
    params.require(:app).permit(:app_no, :name, :price, :description, :create_report, :status, :user_id, :analysis_id, :category_id, :cover_image, :panel)
  end

  def require_admin
    authenticate_account!
    unless account_signed_in? and current_account.has_role? :admin
      if account_signed_in?
        flash[:error] = "You must be an admin to access this page. (Current role: " + current_account.roles.first.name + ")"
      end
      redirect_to root_path
    end
  end

  def require_producer_or_admin
    authenticate_account!
    unless account_signed_in? and (current_account.has_role? :producer or current_account.has_role? :admin)
      if account_signed_in?
        flash[:error] = "You must be a producer to access this page. (Current role: " + current_account.roles.first.name + ")"
      end
      redirect_to root_path
    end
  end

end
