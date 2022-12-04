class Admin::BaseController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # 500 Error Helper
  if Rails.env.production?
    # Exceptionを補足
    rescue_from Exception, with: :rescue_internal_server_error
  end

  before_action :require_login
  before_action :set_layout_view_variables
  before_action :set_content_header
  before_action :set_paper_trail_whodunnit

  # Cancan method
  load_and_authorize_resource

  layout 'admin/layouts/application'

  # add flash message types
  add_flash_types :success, :info, :warning, :danger

  def current_ability
    @current_ability ||= AdminAbility.new(current_user)
  end

  private

  def user_for_paper_trail
    logged_in? ? current_user.name : "Please Login in" # or whatever
  end

  def record_not_found
    render 'admin/404', status: 404
  end

  def authentication_super_admin!
    redirect_to admins_dashboard_path unless current_user.super_admin?
  end

  def rescue_internal_server_error(exception)
    # Slackに通知
    Slack500.post(request, exception)

    render 'admin/500', status: :internal_server_error, layout: 'application'
  end

  # TODO: remove it cause seem not in use
  def not_authenticated
    flash[:warning] = 'ログインしてください'
    redirect_to admin_login_path
  end

  def set_layout_view_variables
    @layout_view_variables = {
      content_header: {
        header: '',
        subheader: { title: '', url: '' },
        labels: [], # example: {class: 'info', title: 'Opened'}
        breadcrumbs: [] # can be hash {title: '', url: ''} or AR object.
      }
    }
  end

  def set_content_header
    return if request.format == :json # json format dont need content header, so skip this implement checking

    err_message = "You haven't override 'set_content_header' method in '#{params[:controller]}' controller."
    if Rails.env.production?
      ExceptionNotifier.notify(err_message)
    else
      raise err_message
    end
  end
end
