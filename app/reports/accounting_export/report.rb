class AccountingExport::Report < ReportBase
  #############################################################################
  # Overriding function
  #############################################################################
  # when run as CSV - return array of rows for direct writing to CSV
  # when run as HTML - to be consumed by report view via @report_result, or accessors from the class
  def on_run(params)
    header = AccountingExport.header
    result = []

    # Order order_created_at
    start_date =  if @criteria_value_hash.dig(:order_created_at, :from)
                    @criteria_value_hash[:order_created_at][:from].to_date
                  else
                    nil
                  end

    end_date =  if @criteria_value_hash.dig(:order_created_at, :to)
                  @criteria_value_hash[:order_created_at][:to].to_date
                else
                  nil
                end

    shop_from = @criteria_value_hash.dig(:shop_from) ? @criteria_value_hash[:shop_from] : nil

    currency = @criteria_value_hash.dig(:currency) ? @criteria_value_hash[:currency] : nil

    orders = Order.select(" orders.order_id,
                            orders.ship_date,
                            orders.total_price,
                            orders.customer_name,
                            orders.customer_contact,
                            orders.customer_address,
                            orders.hk_tracking_number,
                            orders.tracking_number,
                            unnest(op.order_shop_from) AS shop_from,
                            unnest(op.order_product_name) AS product_name,
                            unnest(op.order_product_price) AS product_price,
                            unnest(op.order_receipt_date) AS receipt_date,
                            unnest(op.order_product_total_cost) AS total_cost,
                            unnest(
                              CASE orders.order_type
                              WHEN 'normal' THEN
                                opay.order_payment_method
                              WHEN 'prepaid' THEN
                                '{扣帳}'
                              END) AS payment_method,
                            unnest(
                              CASE orders.order_type
                              WHEN 'normal' THEN
                                opay.order_payment_price
                              WHEN 'prepaid' THEN
                                ARRAY [orders.total_price]
                              END) AS paid_amount,
                            unnest(
                              CASE orders.order_type
                              WHEN 'normal' THEN
                                opay.order_paid_date
                              WHEN 'prepaid' THEN
                                ARRAY [orders.order_created_at]
                              END) AS paid_date")
                  .joins("LEFT JOIN(
                            SELECT
                              op.order_id,
                              array_agg(op.shop_from) AS order_shop_from,
                              array_agg(op.product_name) AS order_product_name,
                              array_agg(op.product_price) AS order_product_price,
                              array_agg(op.total_cost) AS order_product_total_cost,
                              array_agg(op.receipt_date) AS order_receipt_date
                            FROM
                              order_products op
                            GROUP BY
                              op.order_id) op ON orders.id = op.order_id")
                  .joins("LEFT JOIN(
                            SELECT
                              op.order_id,
                              array_agg(op.payment_method) AS order_payment_method,
                              array_agg(op.paid_amount) AS order_payment_price,
                              array_agg(op.paid_date) AS order_paid_date
                            FROM
                              order_payments op
                            GROUP BY
                              op.order_id) opay ON orders.id = opay.order_id")

    # TODO: refactor the report !!
    # Special process to filter the shop_from column
    # Temp to use
    # unnest(opay.order_payment_method) AS payment_method,
    # unnest(opay.order_payment_price) AS paid_amount,
    # unnest(opay.order_paid_date) AS paid_date
    if shop_from.present?
      orders = Order.select(" orders.order_id,
                              orders.ship_date,
                              orders.total_price,
                              orders.customer_name,
                              orders.customer_contact,
                              orders.customer_address,
                              orders.hk_tracking_number,
                              orders.tracking_number,
                              op.shop_from,
                              unnest(op.order_product_name) AS product_name,
                              unnest(op.order_product_price) AS product_price,
                              unnest(op.order_product_total_cost) AS total_cost,
                              unnest(op.order_receipt_date) AS receipt_date,
                              unnest(
                                CASE orders.order_type
                                WHEN 'normal' THEN
                                  opay.order_payment_method
                                WHEN 'prepaid' THEN
                                  '{扣帳}'
                                END) AS payment_method,
                              unnest(
                                CASE orders.order_type
                                WHEN 'normal' THEN
                                  opay.order_payment_price
                                WHEN 'prepaid' THEN
                                  ARRAY [orders.total_price]
                                END) AS paid_amount,
                              unnest(
                                CASE orders.order_type
                                WHEN 'normal' THEN
                                  opay.order_paid_date
                                WHEN 'prepaid' THEN
                                  ARRAY [orders.order_created_at]
                                END) AS paid_date")
                    .joins("LEFT JOIN(
                            SELECT
                              op.order_id,
                              op.shop_from,
                              array_agg(op.product_name) AS order_product_name,
                              array_agg(op.product_price) AS order_product_price,
                              array_agg(op.total_cost) AS order_product_total_cost,
                              array_agg(op.receipt_date) AS order_receipt_date
                            FROM
                              order_products op
                            WHERE
                              op.shop_from = '#{shop_from}'
                            GROUP BY
                              op.order_id,
                              op.shop_from) op ON orders.id = op.order_id")
                    .joins("LEFT JOIN(
                            SELECT
                              op.order_id,
                              array_agg(op.payment_method) AS order_payment_method,
                              array_agg(op.paid_amount) AS order_payment_price,
                              array_agg(op.paid_date) AS order_paid_date
                            FROM
                              order_payments op
                            GROUP BY
                              op.order_id) opay ON orders.id = opay.order_id")
                    .where("op.shop_from = :shop_from", shop_from: shop_from)
    end

    if currency.present?
      orders = order.where('orders.currency = :currency', currency: currency)
    end

    if start_date.present? && end_date.present?
      orders =
        orders.where('orders.order_created_at BETWEEN :from AND :to',
                      from: start_date.beginning_of_day.utc, 
                      to: end_date.end_of_day.utc)
    end

    case format
    when 'html'
      # TODO: show result in html
    when 'csv', 'tsv', 'xlsx'
      orders.each do |order|
        hash = {}
        AccountingExport.export(order).each_with_index do |element, index|
          hash[header[index]] = element
        end
        result << hash
      end
      cols_data_type = AccountingExport.cols_data_type
      cols_style = AccountingExport.cols_style
      return ReportResult.new(data: result, headers: header, cols_data_type: cols_data_type, cols_style: cols_style, format: format, report: self)
    end
  end

  # Define criteria for the report
  def define_criteria(criteria)
    criteria.add_criterion(ReportCriterionDefinition.new(code: :order_created_at, type: :date_range_default_blank, model: Order, view_code: :order_created_at))
    criteria.add_criterion(ReportCriterionDefinition.new(code: :currency, type: :enum_default_blank, enum: Order::CURRENCYS, enum_translation: false, model: Order, view_code: :currency))
    criteria.add_criterion(ReportCriterionDefinition.new(code: :shop_from, type: :enum_default_blank, enum: SystemSetting.get('order.preset.shop_from'), enum_translation: false, model: OrderProduct, view_code: :shop_from))
  end

  def on_validate
    if params.dig(:criteria, :order_created_at).present?
      validate_date_range(Order.human_attribute_name(:order_created_at), params[:criteria][:order_created_at])
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
    # report_title = {
    #   layer1: {
    #     blank: {
    #       merge_cell_size: "A1:A2",
    #       merge_cell_data: [""]
    #     },
    #     order: {
    #       merge_cell_size: "B1:D2",
    #       merge_cell_data: [I18n.t(:'reports.order_export.customer_title'), "", ""],
    #       title_style: :header
    #     },
    #     order_product: {
    #       merge_cell_size: "E1:G2",
    #       merge_cell_data: [I18n.t(:'reports.order_export.product_title'), "", ""],
    #       title_style: :header
    #     },
    #     order_shipment: {
    #       merge_cell_size: "H1:L2",
    #       merge_cell_data: [I18n.t(:'reports.order_export.shipment_title'), "", "", "", ""],
    #       title_style: :header
    #     }
    #   }
    # }
    report_title = {}
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
  class AccountingExport
    ###########################################################################
    # CONSTANT
    ###########################################################################
    FIELDS = %i[
      order_id customer_name customer_contact customer_address
      tracking_number hk_tracking_number
      product_name product_price total_price
      ship_date paid_amount paid_date payment_method 
      total_cost receipt_date
    ].freeze

    FIELD_MAPS = {
      order_id: { type: :field, display: Order.human_attribute_name(:order_id) },
      customer_name: { type: :field, display: Order.human_attribute_name(:customer_name) },
      customer_contact: { type: :field, display: Order.human_attribute_name(:customer_contact) },
      customer_address: { type: :field, display: Order.human_attribute_name(:customer_address) },
      tracking_number: { type: :field, display: Order.human_attribute_name(:tracking_number) },
      hk_tracking_number: { type: :field, display: Order.human_attribute_name(:hk_tracking_number) },
      total_price: { type: :field, display: Order.human_attribute_name(:total_price) },
      ship_date: { type: :date, display: Order.human_attribute_name(:ship_date), col_data_type: :date },
      product_name: { type: :field, display: OrderProduct.human_attribute_name(:product_name) },
      product_price: { type: :field, display: OrderProduct.human_attribute_name(:product_price) },
      paid_amount: { type: :field, display: OrderPayment.human_attribute_name(:paid_amount) },
      paid_date: { type: :date, display: OrderPayment.human_attribute_name(:paid_date), col_data_type: :date },
      payment_method: { type: :field, display: OrderPayment.human_attribute_name(:payment_method) },
      total_cost: { type: :field, display: OrderProduct.human_attribute_name(:total_cost) },
      receipt_date: { type: :date, display: OrderProduct.human_attribute_name(:receipt_date), col_data_type: :date }
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
        when :field
          result << order[field]
        when :date
          # TODO: change the time format to '%Y-%m-%d %H:%M' ?
          result << (order[field].present? ? order[field].in_time_zone('Japan').strftime('%Y/%m/%d') : nil)
        end
      end
      result
    end
  end
end
