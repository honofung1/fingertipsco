class Admin::UserSessionsController < Admin::BaseController
  # Todo : add check admin function
  # skip_before_action :check_admin, only: %i[new create]
  skip_before_action :require_login, only: %i[new create], raise: false

  layout 'admin/layouts/admin_login'

  def new
    # Todo
  end

  def create
    @admin = login(params[:username], params[:password])
    if @admin
      redirect_to
    else
      flash.now[:danger] = "ログインに失敗しました"
      render :new
    end
  end

  def edit
    # Todo
  end

  def destroy
    logout
    redirect_to admin_login_path, success: 'ログアウトしました'
  end
end
