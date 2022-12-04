class Admin::DepositRecordsController < Admin::BaseController
  before_action :set_deposit_record, only: [:show, :edit, :update, :destroy]
  before_action :set_content_header

  def index
    @q = DepositRecord.ransack(params[:q])
    @q.sorts = ['deposit_date desc'] if @q.sorts.empty?
    @deposit_records = @q.result(distinct: true).includes(:order_owner).page(params[:page])
  end

  def new
    @deposit_record = DepositRecord.new
  end

  def create
    @deposit_record = DepositRecord.new(deposit_record_params)

    if @deposit_record.save
      redirect_to admin_deposit_records_path, success: t(:'message.create_success', header_name: DepositRecord.model_name.human)
    else
      flash.now[:danger] = @deposit_record.errors.full_messages.join("/")
      render :new
    end
  end

  def edit
    # Nothing here
  end

  def update
    if @deposit_record.update(deposit_record_params)
      redirect_to admin_deposit_records_path, success: t(:'message.update_success', header_name: DepositRecord.model_name.human)
    else
      flash.now[:danger] = @deposit_record.errors.full_messages.join("/")
      render :edit
    end
  end

  def destroy
    if @deposit_record.destroy
      redirect_to admin_deposit_records_path, success: t(:'message.destroy_success', header_name: DepositRecord.model_name.human)
    else
      redirect_to admin_deposit_records_path, danger: @deposit_record.errors.full_messages.join('')
    end
  end

  private

  def set_deposit_record
    @deposit_record = DepositRecord.find(params[:id])
  end

  def deposit_record_params
    permitted = [
      :order_owner_id, :deposit_amount, :deposit_date
    ]

    params.require(:deposit_record).permit(*permitted)
  end

  def set_content_header
    content_header =
      case params[:action]
      when "index", "new", "create"
        title = DepositRecord.model_name.human(count: 2)
        {
          header: params[:action] == "index" ? title : "#{t(:'button.new')} #{t(:'deposit_record.header_name')}",
          subheader: can?(:create, DepositRecord) && params[:action] == "index" ? {title: t(:'button.add_new'), url: new_admin_deposit_record_path} : {},
          labels: [],
          breadcrumbs: [
            { title: title, url: admin_deposit_records_path }
          ]
        }
      when "show", "edit", "update"
        title = t(:'deposit_record.header_name')
        {
          header: params[:action] == "show" ? title : "#{t(:'button.edit')} #{t(:'deposit_record.header_name')}",
          subheader: {},
          labels: [],
          breadcrumbs: [
            { title: DepositRecord.model_name.human(count: 2), url: admin_deposit_records_path },
            @deposit_record
          ]
        }
      end

    # override default content_header
    @layout_view_variables[:content_header] = content_header
  end
end
