class OrderCostExport::Report < ReportBase
  #############################################################################
  # Overriding function
  #############################################################################
  # when run as CSV - return array of rows for direct writing to CSV
  # when run as HTML - to be consumed by report view via @report_result, or accessors from the class
  def on_run(params)
    header = OrderCostExport.header
    result = []

    @start_date = if @criteria_value_hash.dig(:order_created_at, :from)
                    @criteria_value_hash[:order_created_at][:from].to_date
                  else
                    nil
                  end

    @end_date = if @criteria_value_hash.dig(:order_created_at, :to)
                  @criteria_value_hash[:order_created_at][:to].to_date
                else
                  nil
                end

    # order_costs =Order.joins('LEFT JOIN order_products ON order_products.order_id = orders.id').select('orders.order_id,order_products.product_cost,order_products.shipment_cost,order_products.discount,order_products.total_cost,order_products.receipt_date').order(:id, 'orders.order_id')
    order_costs =
      Order.joins('LEFT JOIN order_products ON order_products.order_id = orders.id')
           .select('orders.order_id,
                    order_products.product_cost,
                    order_products.shipment_cost,
                    order_products.discount,
                    order_products.total_cost,
                    order_products.receipt_date')
           .order(:id, 'orders.order_id')

    if @start_date.present? && @end_date.present?
      # order_costs.where('orders.order_created_at BETWEEN :from AND :to',from: @start_date.beginning_of_day.utc, to: @end_date.end_of_day.utc)
      order_costs =
        order_costs.where('orders.order_created_at BETWEEN :from AND :to',
                          from: @start_date.beginning_of_day.utc,
                          to: @end_date.end_of_day.utc)
    end

    case format
    when 'html'
      # TODO: show result in html
    when 'csv', 'tsv', 'xlsx'
      order_costs.each do |order_cost|
        hash = {}
        OrderCostExport.export(order_cost).each_with_index do |element, index|
          hash[header[index]] = element
        end
        result << hash
      end
      cols_data_type = OrderCostExport.cols_data_type
      cols_style = OrderCostExport.cols_style
      # return ReportResult.new(data: result, headers: header, cols_data_type: cols_data_type, format: format, report: self)
      return ReportResult.new(data: result, headers: header, cols_data_type: cols_data_type, cols_style: cols_style, format: format, report: self)
    end
  end

  # Define criteria for the report
  def define_criteria(criteria)
    criteria.add_criterion(ReportCriterionDefinition.new(code: :order_created_at, type: :date_range_default_blank, model: Order, view_code: :order_created_at))
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
                                        bg_color: 'FCE4D6',
                                        sz: 12,
                                        border: Axlsx::STYLE_THIN_BORDER,
                                        alignment: { horizontal: :center, vertical: :center, wrap_text: true }),

      # header
      header: worksheet.styles.add_style(font_name: '游ゴシック',
                                         bg_color: 'FCE4D6',
                                         sz: 12,
                                         border: Axlsx::STYLE_THIN_BORDER,
                                         alignment: { horizontal: :center, vertical: :center, wrap_text: true }),

      # text
      text: worksheet.styles.add_style(font_name: '游ゴシック',
                                       bg_color: 'FCE4D6',
                                       sz: 12,
                                       border: Axlsx::STYLE_THIN_BORDER,
                                       alignment: { horizontal: :center, vertical: :center}),
      # hyperlink
      hyperlink: worksheet.styles.add_style(font_name: 'Arial', u: true, fg_color: '000000FF')
    }
    styles
  end

  def report_title
    report_title = {
      layer1: {
        # order_cost: { merge_cell_size: "A1:F2", display_name: I18n.t(:'reports.order_cost_export.order_cost_report_title') }
        order_cost: {
          merge_cell_size: "A1:F2",
          merge_cell_data: [I18n.t(:'reports.order_cost_export.order_cost_report_title'), "", "", "", "", ""]
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
  class OrderCostExport
    ###########################################################################
    # CONSTANT
    ###########################################################################
    FIELDS = %i[order_id product_cost shipment_cost discount total_cost receipt_date]
    FIELD_MAPS = {
      order_id: { type: :field, display: Order.human_attribute_name(:order_id) },
      product_cost: { type: :field, display: OrderProduct.human_attribute_name(:product_cost), col_data_type: :integer },
      shipment_cost: { type: :field, display: OrderProduct.human_attribute_name(:shipment_cost), col_data_type: :integer },
      discount: { type: :field, display: OrderProduct.human_attribute_name(:discount), col_data_type: :integer },
      total_cost: { type: :field, display: OrderProduct.human_attribute_name(:total_cost), col_data_type: :integer },
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

    def self.export(order_cost)
      result = []

      FIELDS.collect do |field|
        case FIELD_MAPS[field][:type]
        when :field
          result << order_cost[field]
          # order_cost[field]
        when :date
          # TODO: change the time format to '%Y-%m-%d %H:%M' ?
          result << (order_cost[field].present? ? order_cost[field].in_time_zone('Japan').strftime('%Y/%m/%d') : nil)
        end
      end
      result
    end
  end
end
