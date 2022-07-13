class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: %i[show edit update destroy]
  before_action :set_content_header

  def index
    # TODO: sorting
    @q = Order.ransack(params[:q])
    @orders = @q.result(distinct: true).includes(:order_owner, :order_payments, :order_products).page(params[:page])
    logger.debug("Testing For Loogger")
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      redirect_to admin_orders_path, success: t(:'message.create_success', header_name: Order.model_name.human)
    else
      flash.now[:alert] = @order.errors
      render :new
    end
  end

  def edit
    # Nothing here
  end

  def update
    if @order.update(order_params)
      redirect_to admin_orders_path, success: t(:'message.update_success', header_name: Order.model_name.human)
    else
      flash.now[:danger] = @order.errors.full_messages.join("/")
      render :edit
    end
  end

  def destroy
    if @order.destroy
      redirect_to admin_orders_path, success: t(:'message.destroy_success', header_name: Order.model_name.human)
    else
      redirect_to admin_orders_path, danger: @order.errors.full_messages.join('')
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    permitted =
      [
        :order_owner_id, :order_id,
        :customer_name, :customer_contact, :customer_address,
        :emergency_call,
        order_products_attributes:
          [
            :id,
            :shop_from,
            :product_name, :product_remark, :prodcut_quantity, :product_price,
            :receive_number, :hk_tracking_number, :tracking_number,
            :state, :ship_date,
            :product_cost, :shipment_cost, :discount, :total_cost,
            :receipt_date,
            :_destroy
          ],
        order_payments_attributes:
          [
            :id,
            :payment_method, :paid_amount, :paid_date,
            :_destroy
          ]
      ]

    params.require(:order).permit(*permitted)
  end

  def set_content_header
    content_header = case params[:action]
    when "index", "new", "create"
      title = Order.model_name.human(count: 2)
      {
        header: params[:action] == "index" ? title : "#{t(:'button.new')} #{t(:'order.header_name')}",
        subheader: can?(:create, Order) && params[:action] == "index" ? {title: t(:'button.add_new'), url: new_admin_order_path} : {},
        labels: [],
        breadcrumbs: [
          { title: title, url: admin_orders_path }
        ]
      }
    when "show", "edit", "update"
      title = t(:'order.header_name')
      {
        header: params[:action] == "show" ? title: "#{t(:'button.edit')} #{t(:'order.header_name')}",
        subheader: {},
        labels: [],
        breadcrumbs: [
          { title: Order.model_name.human(count: 2), url: admin_orders_path },
          @order
        ]
      }
    end

    # override default content_header
    @layout_view_variables[:content_header] = content_header
  end

end
