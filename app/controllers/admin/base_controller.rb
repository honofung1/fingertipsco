class Admin::BaseController < ApplicationController   
  layout 'admin/layouts/application'

  private

  def not_authenticated
    flash[:warning] = 'ログインしてください'
    redirect_to admin_login_path
  end
end
