class Admin::AdminsController < Admin::BaseController

  before_action :set_admin, only: %i[show edit update destroy]
  before_action :set_content_header

  def index
    @admins = Admin.all
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)

    if @admin.save
      redirect_to admin_admins_path, success: t(:'message.create_success', header_name: Admin.model_name.human)
    else
      flash.now[:alert] = @admin.errors.full_messages.join("/")
      render :new
    end
  end

  def edit
    # Nothing here
  end

  def update
    if @admin.update(admin_params)
      redirect_to admin_admins_path, success: t(:'message.update_success', header_name: Admin.model_name.human)
    else
      flash.now[:danger] = @admin.errors.full_messages.join("/")
      render :edit
    end
  end

  def show
    # Nothing here
  end

  def destroy
    if @admin.destroy
      redirect_to admin_admins_path, success: t(:'message.destroy_success', header_name: Admin.model_name.human)
    else
      redirect_to admin_admins_path, danger: @admin.errors.full_messages.join('')
    end
  end

  private

  def set_admin
    @admin = Admin.find(params[:id])
  end

  def admin_params
    permitted = [:name, :username, :role, :password, :password_confirmation]

    params.require(:admin).permit(*permitted)
  end

  def set_content_header
    content_header = case params[:action]
    when "index", "new", "create"
      title = Admin.model_name.human(count: 2)
      {
        header: params[:action] == "index" ? title : "#{t(:'button.new')} #{t(:'admin.header_name')}",
        subheader: can?(:create, Admin) && params[:action] == "index" ? {title: t(:'button.add_new'), url: new_admin_admin_path} : {},
        labels: [],
        breadcrumbs: [
          { title: title, url: admin_admins_path }
        ]
      }
    when "show", "edit", "update"
      title = t(:'admin.header_name')
      {
        header: params[:action] == "show" ? title: "#{t(:'button.edit')} #{t(:'admin.header_name')}",
        subheader: {},
        labels: [],
        breadcrumbs: [
          { title: Admin.model_name.human(count: 2), url: admin_admins_path },
          @admin
        ]
      }
    end

    # override default content_header
    @layout_view_variables[:content_header] = content_header
  end

end