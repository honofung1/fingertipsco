class PrepaidOrderExport::Report < ReportBase
  #############################################################################
  # Overriding function
  #############################################################################
  # when run as CSV - return array of rows for direct writing to CSV
  # when run as HTML - to be consumed by report view via @report_result, or accessors from the class
  def on_run(params)
    header = PrepaidOrderExport.header
    result = []

    order_owner_id = if @criteria_value_hash.dig(:order_owner_id)
                       @criteria_value_hash[:order_owner_id]
                     else
                       nil
                     end

    # Order order_created_at
    start_date = if @criteria_value_hash.dig(:order_created_at, :from)
                   @criteria_value_hash[:order_created_at][:from].to_date
                 else
                   nil
                 end

    end_date = if @criteria_value_hash.dig(:order_created_at, :to)
                 @criteria_value_hash[:order_created_at][:to].to_date
               else
                 nil
               end

    # Order ship date
    ship_start_date = if @criteria_value_hash.dig(:ship_date, :from)
                        @criteria_value_hash[:ship_date][:from].to_date
                      else
                        nil
                      end

    ship_end_date = if @criteria_value_hash.dig(:ship_date, :to)
                      @criteria_value_hash[:ship_date][:to].to_date
                    else
                      nil
                    end

    # order_costs =Order.joins('LEFT JOIN order_products ON order_products.order_id = orders.id').select('orders.order_id,order_products.product_cost,order_products.shipment_cost,order_products.discount,order_products.total_cost,order_products.receipt_date').order(:id, 'orders.order_id')
    orders =
      Order.prepaid_order
           .joins('LEFT JOIN order_products ON order_products.order_id = orders.id')
           .joins('LEFT JOIN order_owners ON orders.order_owner_id = order_owners.id')
           .select("order_owners.order_code_prefix,
                    orders.order_id,
                    orders.order_created_at,
                    order_products.shop_from,
                    order_products.product_name,
                    order_products.product_price * product_quantity AS product_price,
                    orders.handling_amount,
                    orders.additional_amount,
                    orders.total_price,
                    orders.receive_number,
                    orders.hk_tracking_number,
                    orders.tracking_number,
                    CASE
                      WHEN orders.state = 6 THEN 'prepaided'
                      WHEN orders.state = 7 THEN 'received'
                      WHEN orders.state = 8 THEN 'shipped'
                      WHEN orders.state = 9 THEN 'printed'
                    END AS order_state,
                    orders.ship_date,
                    orders.remark")
           .order(:id, 'orders.order_id')

    if start_date.present? && end_date.present?
      # order_costs.where('orders.order_created_at BETWEEN :from AND :to',from: @start_date.beginning_of_day.utc, to: @end_date.end_of_day.utc)
      orders =
        orders.where('orders.order_created_at BETWEEN :from AND :to',
                     from: start_date.beginning_of_day.utc,
                     to: end_date.end_of_day.utc)
    end

    if ship_start_date.present? && ship_end_date.present?
      orders =
        orders.where('orders.ship_date BETWEEN :from AND :to',
                     from: ship_start_date.beginning_of_day.utc,
                     to: ship_end_date.end_of_day.utc)
    end

    if order_owner_id.present?
      orders =
        orders.where('order_owners.id': order_owner_id)
    end

    case format
    when 'html'
      # TODO: show result in html
    when 'csv', 'tsv', 'xlsx'
      orders.each do |order|
        hash = {}
        PrepaidOrderExport.export(order).each_with_index do |element, index|
          hash[header[index]] = element
        end
        result << hash
      end
      cols_data_type = PrepaidOrderExport.cols_data_type
      cols_style = PrepaidOrderExport.cols_style
      return ReportResult.new(data: result, headers: header, cols_data_type: cols_data_type, cols_style: cols_style, format: format, report: self)
    end
  end

  # Define criteria for the report
  def define_criteria(criteria)
    # Order Owner selector
    criteria.add_criterion(ReportCriterionDefinition.new(code: :order_owner_id, type: :enum_default_blank, enum: OrderOwner.key_account, enum_object_display_field: :order_code_prefix, model: OrderOwner, view_code: :order_code_prefix))
    # Order created date selector
    criteria.add_criterion(ReportCriterionDefinition.new(code: :order_created_at, type: :date_range_default_blank, model: Order, view_code: :order_created_at))
    # Order ship date selector
    criteria.add_criterion(ReportCriterionDefinition.new(code: :ship_date, type: :date_range_default_blank, model: Order, view_code: :ship_date))

    # TODO: temp to hide the currency and order owner filter
    # criteria.add_criterion(ReportCriterionDefinition.new(code: :currency, type: :enum_default_blank, enum: Order::CURRENCYS, enum_translation: false, model: Order, view_code: :currency))
  end

  def on_validate
    if params.dig(:criteria, :created_at).present?
      validate_date_range(Order.human_attribute_name(:created_at), params[:criteria][:created_at])
    end
  end

  # https://github.com/caxlsx/caxlsx/tree/master/examples
  # There is so many styling can do in the axlsx
  # Please refer the example to styling the xlsx
  # TODO: refactor the styles for DRY
  def style(worksheet)
    styles = {
      # title
      title: worksheet.styles.add_style(font_name: '游ゴシック',
                                        sz: 12,
                                        border: Axlsx::STYLE_THIN_BORDER,
                                        alignment: { horizontal: :center, vertical: :center, wrap_text: true }),
      # header
      header: worksheet.styles.add_style(font_name: '游ゴシック',
                                         sz: 16,
                                         border: Axlsx::STYLE_THIN_BORDER,
                                         alignment: { horizontal: :center, vertical: :center, wrap_text: true }),

      # text
      text: worksheet.styles.add_style(font_name: '游ゴシック',
                                       # bg_color: 'D6DCE4',
                                       sz: 12,
                                       border: Axlsx::STYLE_THIN_BORDER,
                                       alignment: { horizontal: :center, vertical: :center, wrap_text: true }),

      # hyperlink
      hyperlink: worksheet.styles.add_style(font_name: 'Arial', u: true, fg_color: '000000FF')
    }
    styles
  end

  # ABCDEFGHIJKLMNOPQRSTUVWXYZ
  # TODO: add comment for the report title how is working
  # but it is too complicated workload, so do this later
  def report_title
    report_title = {
      layer1: {
        blank: {
          merge_cell_size: "A1:C2",
          merge_cell_data: [I18n.t(:'reports.prepaid_order_export.order_title'), "", ""],
          title_style: :header
        },
        order: {
          merge_cell_size: "D1:I2",
          merge_cell_data: [I18n.t(:'reports.prepaid_order_export.product_title'), "", "", "", "", ""],
          title_style: :header
        },
        order_product: {
          merge_cell_size: "J1:L2",
          merge_cell_data: [I18n.t(:'reports.prepaid_order_export.shipment_title'), "", ""],
          title_style: :header
        }
      }
    }
    report_title
  end

  #############################################################################
  # Private function
  #############################################################################
  private

  def modify
    # Do nothing here for now
  end

  #############################################################################
  # Inner private class
  #############################################################################
  class PrepaidOrderExport
    ###########################################################################
    # CONSTANT
    ###########################################################################
    FIELDS = %i[
      order_code_prefix order_id order_created_at
      shop_from product_name product_price 
      handling_amount additional_amount total_price
      order_state ship_date remark
    ].freeze

    FIELD_MAPS = {
      order_code_prefix: { type: :field, display: OrderOwner.human_attribute_name(:order_code_prefix) },
      order_id: { type: :field, display: Order.human_attribute_name(:order_id) },
      order_created_at: { type: :date, display: Order.human_attribute_name(:order_created_at) },
      shop_from: { type: :field, display: OrderProduct.human_attribute_name(:shop_from) },
      product_name: { type: :field, display: OrderProduct.human_attribute_name(:product_name) },
      product_price: { type: :field, display: OrderProduct.human_attribute_name(:product_price) },
      handling_amount: { type: :field, display: Order.human_attribute_name(:handling_amount) },
      additional_amount: { type: :field, display: Order.human_attribute_name(:additional_amount) },
      total_price: { type: :field, display: Order.human_attribute_name(:total_price) },
      order_state: { type: :state, display: Order.human_attribute_name(:state) },
      ship_date: { type: :date, display: Order.human_attribute_name(:ship_date), col_data_type: :date },
      remark: { type: :field, display: Order.human_attribute_name(:remark) },
    }

    ###########################################################################
    # class method
    ###########################################################################
    def self.header
      headers = []
      FIELDS.each do |field|
        field_map = FIELD_MAPS[field]
        headers << (field_map[:display].presence || field.to_s.titleize)
      end
      headers
    end

    def self.cols_data_type
      FIELDS.collect do |field|
        FIELD_MAPS[field][:col_data_type] || ReportResult.default_excel_col_data_type
      end
    end

    def self.cols_style
      FIELDS.collect do |field|
        FIELD_MAPS[field][:style] || ReportResult.default_col_style
      end
    end

    def self.export(order)
      result = []

      FIELDS.collect do |field|
        case FIELD_MAPS[field][:type]
        when :state
          result << I18n.t(:"enums.order.#{order[field]}")
        when :field
          result << order[field]
          # order_cost[field]
        when :date
          # TODO: change the time format to '%Y-%m-%d %H:%M' ?
          result << (order[field].present? ? order[field].in_time_zone('Japan').strftime('%Y/%m/%d') : nil)
        end
      end
      result
    end
  end
end
