class OrderExport::Report < ReportBase
  #############################################################################
  # Overriding function
  #############################################################################
  # when run as CSV - return array of rows for direct writing to CSV
  # when run as HTML - to be consumed by report view via @report_result, or accessors from the class
  def on_run(params)
    header = OrderExport.header
    result = []

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

    # Order Product ship date
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
      Order.joins('LEFT JOIN order_products ON order_products.order_id = orders.id')
           .select("orders.order_id,
                    CASE
                      WHEN orders.state = 0 THEN 'notpaid'
                      WHEN orders.state = 1 THEN 'paidpartly'
                      WHEN orders.state = 2 THEN 'fullpaid'
                      WHEN orders.state = 3 THEN 'finished'
                      WHEN orders.state = 4 THEN 'accounted'
                      WHEN orders.state = 5 THEN 'cancelled'
                    END AS order_state,
                    order_products.shop_from,
                    order_products.product_name,
                    order_products.product_remark,
                    order_products.ship_date")
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
        orders.where('order_products.ship_date BETWEEN :from AND :to',
                     from: ship_start_date.beginning_of_day.utc,
                     to: ship_end_date.end_of_day.utc)
    end

    case format
    when 'html'
      # TODO: show result in html
    when 'csv', 'tsv', 'xlsx'
      orders.each do |order|
        hash = {}
        OrderExport.export(order).each_with_index do |element, index|
          hash[header[index]] = element
        end
        result << hash
      end
      cols_data_type = OrderExport.cols_data_type
      cols_style = OrderExport.cols_style
      return ReportResult.new(data: result, headers: header, cols_data_type: cols_data_type, cols_style: cols_style, format: format, report: self)
    end
  end

  # Define criteria for the report
  def define_criteria(criteria)
    # TODO: Need to confirm with kylie
    # criteria.add_criterion(ReportCriterionDefinition.new(code: :order_owner_id, type: :enum_default_blank, enum: OrderOwner.all, enum_object_display_field: :order_code_prefix, model: OrderOwner, view_code: :order_code_prefix))
    criteria.add_criterion(ReportCriterionDefinition.new(code: :order_created_at, type: :date_range_default_blank, model: Order, view_code: :order_created_at))
    # Order product ship date selector
    # Example for the order
    criteria.add_criterion(ReportCriterionDefinition.new(code: :ship_date, type: :date_range_default_blank, model: OrderProduct, view_code: :ship_date))
    # TODO: temp to hide it
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
  def report_title
    report_title = {
      layer1: {
        order_processor: {
          merge_cell_size: "A1:G2",
          merge_cell_data: [I18n.t(:'reports.order_export.order_processor_report_title'), "", "", "", "", "", ""],
          title_style: :header
        }
      },
      layer2: {
        order: {
          merge_cell_size: "A3:A4",
          merge_cell_data: [I18n.t(:'reports.order_export.order_report_title')]
        },
        order_product: {
          merge_cell_size: "B3:D4",
          merge_cell_data: [I18n.t(:'reports.order_export.order_product_report_title'), "", ""]
        },
        order_shipment: {
          merge_cell_size: "E3:F4",
          merge_cell_data: [I18n.t(:'reports.order_export.order_shipment_report_title'), ""]
        },
        order_check: {
          merge_cell_size: "G3:G4",
          merge_cell_data: [I18n.t(:'reports.order_export.order_check_report_title')]
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
  class OrderExport
    ###########################################################################
    # CONSTANT
    ###########################################################################
    FIELDS = %i[order_id shop_from product_name product_remark order_state ship_date checking].freeze

    FIELD_MAPS = {
      order_id: { type: :field, display: Order.human_attribute_name(:order_id) },
      shop_from: { type: :field, display: OrderProduct.human_attribute_name(:shop_from) },
      product_name: { type: :field, display: OrderProduct.human_attribute_name(:product_name) },
      product_remark: { type: :field, display: OrderProduct.human_attribute_name(:product_remark) },
      order_state: { type: :state, display: Order.human_attribute_name(:state) },
      ship_date: { type: :date, display: OrderProduct.human_attribute_name(:ship_date), col_data_type: :date },
      # the checking field is for the check manually and there is no database data here,
      # just a dummy column
      checking: { type: :field, display: "✔︎" }
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
