class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: %i[show edit update destroy]
  before_action :set_content_header

  # should be before set_content_header
  # so that the set_content_header can use the order owner to handle action
  prepend_before_action :set_order_owner
  prepend_before_action :handle_order_product_shipment_info, only: %i[create update]

  def index
    # TODO: sorting
    @q = Order.ransack(params[:q])

    sorting_logic = if @order_owner.present?
                      ['emergency_call desc', 'state asc', 'order_id desc']
                    else
                      ['emergency_call desc', 'state asc', 'updated_at desc', 'order_created_at desc']
                    end

    @q.sorts = sorting_logic if @q.sorts.empty?
    @orders = @q.result(distinct: true).includes(:order_owner, :order_payments, :order_products).page(params[:page])

    @orders = if @order_owner.present?
                @orders.where(order_owner: @order_owner)
              else
                @orders.where(order_type: Order::ORDER_TYPE_NORMAL)
              end

    # Render special index for PREPAID type order
    if params[:type].present? && params[:type] == Order::ORDER_TYPE_PREPAID
      render 'index_prepaid'
    end
  end

  def new
    @order = Order.new(order_type: Order::ORDER_TYPE_NORMAL)

    return unless @order_owner.present?

    # Change it to PREPAID type
    # Preapre the data
    @order.order_owner = @order_owner
    @order.order_type = Order::ORDER_TYPE_PREPAID
    @order.state = "prepaided"
    @order.customer_name = @order_owner.name
    @order.customer_contact = @order_owner.telephone
    @order.customer_address = @order_owner.addresses
    @order.currency = "JPY"
  end

  def create
    @order = Order.new(order_params)

    @order = OrderCalculationService.new(@order).call

    if @order.save
      redirect_to corresponding_order_type_action_path(@order), success: t(:'message.create_success', header_name: Order.model_name.human)
    else
      flash.now[:danger] = @order.errors.full_messages.join("\n")
      @order_owner = @order.order_owner if @order.order_type == Order::ORDER_TYPE_PREPAID
      render :new
    end
    # TODO: log the order create action for tracing
    # logger.debug("Testing For Loogger")
  end

  # This is for normal type order only
  def clone
    @order = Order.find(params[:id]).clone_order
    @order.state = "notpaid"
    render 'new'
  end

  def show
    # It means the order type is prepaid
    if @order_owner.present?
      render 'show_prepaid'
    else
      # otherwise show order normally
      render 'show'
    end
  end

  def edit
    # Nothing here
  end

  def update
    @order.attributes = order_params

    # prepaid order only have one product or prepare a fake product for no product prepaid order
    order_product = @order.order_products.first || OrderProduct.new

    # TODO: refactor this temp solution !!!!
    # this solution is for one situation
    # when order owner updated their handling fee
    # and prevent old order to using new handling fee
    # when old order don't have the price related column changed
    # it will not call order calculation service
    order_need_recal =
      order_product.will_save_change_to_product_quantity? ||
      order_product.will_save_change_to_product_price? ||
      @order.will_save_change_to_additional_fee? ||
      @order.will_save_change_to_additional_fee_type?

    @order = OrderCalculationService.new(@order).call if order_need_recal

    unless AdminUpdateOrderValidationService.new(current_user, @order).validate
      @order.errors.add(:total_price, I18n.t(:'message.modify_denied'))
      flash.now[:danger] = @order.errors.full_messages.join("\n")
      render :edit
      return
    end

    if @order.save
      redirect_to corresponding_order_type_action_path(@order), success: t(:'message.update_success', header_name: Order.model_name.human)
    else
      flash.now[:danger] = @order.errors.full_messages.join("\n")
      render :edit
    end
  end

  def destroy
    if @order.destroy
      redirect_to corresponding_order_type_action_path(@order), success: t(:'message.destroy_success', header_name: Order.model_name.human)
    else
      redirect_to corresponding_order_type_action_path(@order), danger: @order.errors.full_messages.join('')
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def set_order_owner
    @order_owner = OrderOwner.find(params[:order_owner_id]) unless params[:order_owner_id].nil?
  end

  def order_params
    permitted =
      [
        :order_owner_id, :order_id,
        :customer_name, :customer_contact, :customer_address, :currency,
        :emergency_call, :pickup_way, :state, :remark,
        :receive_number, :hk_tracking_number, :tracking_number, :ship_date, :order_type,
        :additional_fee, :additional_fee_type,
        order_products_attributes:
          [
            :id,
            :shop_from,
            :product_name, :product_remark, :product_quantity, :product_price,
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
      title = t(:'order.header_name')
      order_owner_name = @order_owner.name || "" if @order_owner.present?
      {
        header: params[:action] == "index" ? I18n.t('sidebar.order') : "#{t(:'button.new')} #{order_owner_name} #{t(:'order.header_name')}",
        subheader: can?(:create, Order) && params[:action] == "index" ? { title: t(:'button.add_new'), url: @order_owner.present? ? new_admin_order_owner_order_path(@order_owner.id, type: "prepaid") : new_admin_order_path } : {},
        labels: [],
        breadcrumbs: [
          { title: title, url: @order_owner.present? ? admin_order_owner_orders_path(@order_owner.id, type: "prepaid") : admin_orders_path, index_enable_href: true } 
        ]
      }
    when "show", "edit", "update"
      title = t(:'order.header_name')
      {
        header: params[:action] == "show" ? title : "#{t(:'button.edit')} #{order_owner_name} #{t(:'order.header_name')}",
        subheader: {},
        labels: [],
        breadcrumbs: [
          { title: Order.model_name.human(count: 2), url: @order_owner.present? ? admin_order_owner_orders_path(@order_owner.id, type: "prepaid") : admin_orders_path },
          { title: @order.order_id, url: @order_owner.present? ? admin_order_owner_order_path(@order_owner.id) : admin_order_path(@order) }
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

  def corresponding_order_type_action_path(order)
    order.order_type == Order::ORDER_TYPE_NORMAL ? admin_orders_path : admin_order_owner_orders_path(order.order_owner, type: "prepaid")
  end
end
