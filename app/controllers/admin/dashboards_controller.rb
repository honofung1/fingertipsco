class Admin::DashboardsController < Admin::BaseController

  # Skip cancan to avoid raising error
  skip_load_and_authorize_resource

  def index
    # Nothing here
  end

  # require_login
  def check_login
    redirect_to admin_login_path unless current_user.present?
  end

  def set_content_header
    content_header = case params[:action]
    when "index"
      title = t(:'sidebar.dashboard')
      {
        header: title,
        subheader: { title: "Control panel" },
        labels: [],
        breadcrumbs: [
          {title: title}
        ]
      }
    end
      # override default content_header
      @layout_view_variables[:content_header] = content_header
  end

end
