class Admin::UserSessionsController < Admin::BaseController
  # TODO : add check admin function
  # skip_before_action :check_admin, only: %i[new create]
  skip_before_action :require_login, only: %i[new create], raise: false

  layout 'admin/layouts/admin_login'

  def new
    # TODO
  end

  def create
    ap "-----"
    ap params[:username]
    ap params[:password]
    @admin = login(params[:username], params[:password])
    if @admin
      redirect_to admin_root_path, success: 'ログインしました'
    else
      flash.now[:danger] = "ログインに失敗しました"
      render :new
    end
  end

  def edit
    # TODO
  end

  def destroy
    logout
    redirect_to admin_login_path, success: 'ログアウトしました'
  end
end
