class Admin::SystemSettingsController < Admin::BaseController
  before_action :set_system_setting, only: [:destroy]
  before_action :set_content_header

  def index
    @q = SystemSetting.ransack(params[:q])
    system_settings = @q.result(distinct: true)

    system_settings = system_settings.order(:name)

    @namespaced_system_settngs_hash = {}
    system_settings.each do |system_setting|
      namespaces = system_setting.name.split('.')

      # ensure @namespaced_system_settngs_hash has THIS system setting namespace
      last_namespace_object = @namespaced_system_settngs_hash # init
      namespaces.each do |namespace|
        last_namespace_object[namespace] ||= {} # init if this namespace not exist yet.
        # stupid but works, so next loop is next level namespace."
        last_namespace_object = last_namespace_object[namespace]
      end

      # inject the THIS system setting object into @namespaced_system_settngs_hash
      last_namespace_object['__object__'] = system_setting
    end
  end

  def new
    @system_setting = SystemSetting.new
  end

  def edit_multiple
    # Get the edit_content
    @system_settings = SystemSetting.where(id: params[:ids])
  end

  def create
    @system_setting = SystemSetting.new(system_setting_params)

    if @system_setting.save
      redirect_to admin_system_settings_path, notice: t(:'message.create_success', header_name: SystemSetting.model_name.human)
    else
      flash.now[:alert] = @system_setting.errors
      render :new
    end
  end

  def update_multiple
    @system_settings = []

    params[:system_settings]&.each do |system_setting_hash|
      if system_setting = SystemSetting.find_by_id(system_setting_hash[:id])
        attributes = [:name, :value_type, :value]
        # in default_system_settng.yml, not allow to modify name.
        attributes -= [:name] if DEFAULT_SYSTEM_SETTINGS.keys.include?(system_setting.name)

        # ALWAYS white list approach
        system_setting_hash = system_setting_hash.permit(*attributes)

        system_setting.attributes = system_setting_hash

        @system_settings << system_setting
      end
    end

    any_fail = false
    SystemSetting.transaction do
      @system_settings.each do |system_setting|
        unless system_setting.save
          any_fail = true
        end
      end
      if any_fail
        raise ActiveRecord::Rollback
      end
    end

    if any_fail
      render :edit_multiple
    else
      # all good
      redirect_to admin_system_settings_path, success: t(:'message.update_success', header_name: SystemSetting.model_name.human)
    end
  end

  def destroy
    if @system_setting.destroy
      redirect_to admin_system_settings_path, success: t(:'message.destroy_success', header_name: SystemSetting.model_name.human)
    else
      redirect_to admin_system_settings_path, danger: @system_setting.errors.full_messages.join('')
    end
  end

  private

  def set_system_setting
    @system_setting = SystemSetting.find(params[:id])
  end

  def system_setting_params
    params.require(:system_setting).permit(:name, :value, :value_type)
  end

  def batch_mode_params
    params.permit(:system_settings => [ :name, :value, :value_type])
  end

  def set_content_header
    content_header =
      case params[:action]
      when "index", "new", "create"
        title = SystemSetting.model_name.human(count: 2)
        {
          header: params[:action] == "index" ? title : "#{t(:'button.new')} #{t(:'system_setting.header_name')}",
          subheader: can?(:create, SystemSetting) && params[:action] == "index" ? {title: t(:'button.add_new'), url: new_admin_system_setting_path} : {},
          labels: [],
          breadcrumbs: [
            { title: title, url: admin_system_settings_path }
          ]
        }
      when "edit_multiple", "update_multiple"
        title = t(:'system_setting.header_name')
        {
          header: params[:action] == "show" ? title : "#{t(:'button.edit')} #{t(:'system_setting.header_name')}",
          subheader: {},
          labels: [],
          breadcrumbs: [
            { title: SystemSetting.model_name.human(count: 2), url: admin_system_settings_path },
            @system_setting
          ]
        }
      end

    # override default content_header
    @layout_view_variables[:content_header] = content_header
  end
end
