class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: %i[show edit update destroy]
  prepend_before_action :handle_order_product_shipment_info, only: %i[create update]
  before_action :set_content_header

  def index
    # TODO: sorting
    @q = Order.ransack(params[:q])
    @q.sorts = ['emergency_call desc', 'state asc', 'updated_at desc', 'order_created_at desc'] if @q.sorts.empty?
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
      flash.now[:danger] = @order.errors.full_messages.join("/")
      render :new
    end
  end

  def clone
    @order = Order.find(params[:id]).clone_order
    @order.state = "notpaid"
    render 'new'
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
        :customer_name, :customer_contact, :customer_address, :currency,
        :emergency_call, :pickup_way, :state, :remark,
        order_products_attributes:
          [
            :id,
            :shop_from,
            :product_name, :product_remark, :product_quantity, :product_price,
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
    when "index", "new", "create", "clone"
      # title = Order.model_name.human(count: 2)
      # 2022/09/05 Kylie request for the specific title
      title = I18n.t('sidebar.order')
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

  # Handle the params data before its begin create/ update
  # The behavior of the order product shipment info is like below:
  # Assume There have an order and its three order poructs
  # -----------------------------------------------
  # |    Order Product  |    Tracking Number      |
  # -----------------------------------------------
  # |         1         |         A123            |
  # -----------------------------------------------
  # |         2         |          ""             |
  # -----------------------------------------------
  # |         3         |         B123            |
  # -----------------------------------------------
  # After processing the shipment info, The data should be changed to the below:
  # -----------------------------------------------
  # |    Order Product  |    Tracking Number      |
  # -----------------------------------------------
  # |         1         |         A123            |
  # -----------------------------------------------
  # |         2         |         A123            |
  # -----------------------------------------------
  # |         3         |         B123            |
  # -----------------------------------------------
  def handle_order_product_shipment_info
    order_product_params = params.dig(:order, :order_products_attributes)

    return if order_product_params.nil?

    # retrieve the first order product tracking number as a default tacking number
    default_product_track_num = order_product_params.values.first['tracking_number']

    return if default_product_track_num.blank?

    order_product_params.each do |_, o|
      order_product_tracking_num = o['tracking_number']
      o['tracking_number'] = order_product_tracking_num.presence || default_product_track_num
    end

  end
end
