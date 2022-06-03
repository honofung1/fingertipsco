class Admin::UserSessionsController < Admin::BaseController
  # TODO : add check admin function
  # skip_before_action :check_admin, only: %i[new create]
  skip_before_action :require_login, only: %i[new create], raise: false
  skip_before_action :set_content_header

  layout 'admin/layouts/admin_login'

  # Skip cancan to avoid raising error
  skip_load_and_authorize_resource

  def new
    # Nothing here
  end

  def create
    @admin = login(params[:username], params[:password])
    if @admin
      redirect_to admin_root_path, success: 'ログインしました'
    else
      flash.now[:danger] = "ログインに失敗しました"
      render :new
    end
  end

  def edit
    # Nothing here
  end

  def destroy
    logout
    redirect_to admin_login_path, success: 'ログアウトしました'
  end
end
