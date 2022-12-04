class Admin::OrderOwnersController < Admin::BaseController
  before_action :set_order_owner, only: [:show, :edit, :update, :destroy]
  before_action :set_content_header

  def index
    @order_owners = OrderOwner.all
  end

  def new
    @order_owner = OrderOwner.new
  end

  def create
    @order_owner = OrderOwner.new(order_owner_params)

    if @order_owner.save
      redirect_to admin_order_owners_path, success: t(:'message.create_success', header_name: OrderOwner.model_name.human)
    else
      flash.now[:danger] = @order_owner.errors.full_messages.join("/")
      render :new
    end
  end

  def edit
    # Nothing here
  end

  def update
    if @order_owner.update(order_owner_params)
      redirect_to admin_order_owners_path, success: t(:'message.update_success', header_name: OrderOwner.model_name.human)
    else
      flash.now[:danger] = @order_owner.errors.full_messages.join("/")
      render :edit
    end
  end

  def destroy
    if @order_owner.destroy
      redirect_to admin_order_owners_path, success: t(:'message.destroy_success', header_name: OrderOwner.model_name.human)
    else
      redirect_to admin_order_owners_path, danger: @order_owner.errors.full_messages.join('')
    end
  end

  private

  def set_order_owner
    @order_owner = OrderOwner.find(params[:id])
  end

  def order_owner_params
    # permitted = OrderOwner.globalize_attribute_names + [:name, :order_code_prefix]
    permitted = [
      :name, :order_code_prefix,
      :telephone, :addresses, :handling_fee
    ]

    params.require(:order_owner).permit(*permitted)
  end

  def set_content_header
    content_header = case params[:action]
    when "index", "new", "create"
      title = OrderOwner.model_name.human(count: 2)
      {
        header: params[:action] == "index" ? title : "#{t(:'button.new')} #{t(:'order_owner.header_name')}",
        subheader: can?(:create, OrderOwner) && params[:action] == "index" ? {title: t(:'button.add_new'), url: new_admin_order_owner_path} : {},
        labels: [],
        breadcrumbs: [
          { title: title, url: admin_order_owners_path }
        ]
      }
    when "show", "edit", "update"
      title = t(:'order_owner.header_name')
      {
        header: params[:action] == "show" ? title : "#{t(:'button.edit')} #{t(:'order_owner.header_name')}",
        subheader: {},
        labels: [],
        breadcrumbs: [
          { title: OrderOwner.model_name.human(count: 2), url: admin_order_owners_path },
          @order_owner
        ]
      }
    end

    # override default content_header
    @layout_view_variables[:content_header] = content_header
  end
end
