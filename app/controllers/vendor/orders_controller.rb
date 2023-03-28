class Vendor::OrdersController < Vendor::BaseController
  before_action :set_order, only: %i[show]
  before_action :set_content_header

  def index
    # filter out printed order for now
    @q = current_user.orders.where.not(state: "printed").ransack(params[:q])

    @q.sorts = ['emergency_call desc', 'state asc', 'order_id desc'] if @q.sorts.empty?
    @orders = @q.result(distinct: true).includes(:order_owner, :order_payments, :order_products).page(params[:page])
  end

  def show
    # Nothing here
  end

  private

  def set_order
    @order = current_user.orders.find_by(order_id: params[:order_id])
  end

  def set_content_header
    content_header =
      case params[:action]
      when "index"
        title = t(:'order.header_name')
        {
          header: I18n.t('sidebar.order'),
          subheader: {},
          labels: [],
          breadcrumbs: [
            { title: title, url: vendor_orders_path, index_enable_href: true }
          ]
        }
      when "show"
        title = t(:'order.header_name')
        {
          header: title,
          subheader: {},
          labels: [],
          breadcrumbs: [
            { title: Order.model_name.human(count: 2), url: vendor_orders_path },
            { title: @order.order_id, url: vendor_orders_path(@order) }
          ]
        }
      end

    # override default content_header
    @layout_view_variables[:content_header] = content_header
  end
end
