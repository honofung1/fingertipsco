class OrderSalesExport::Report < ReportBase
  #############################################################################
  # Overriding function
  #############################################################################
  # when run as CSV - return array of rows for direct writing to CSV
  # when run as HTML - to be consumed by report view via @report_result, or accessors from the class
  def on_run(params)
    header = OrderSalesExport.header
    result = []

    start_date = if @criteria_value_hash.dig(:ship_date, :from)
                   @criteria_value_hash[:ship_date][:from].to_date
                  else
                    nil
                  end

    end_date = if @criteria_value_hash.dig(:order_ship_datecreated_at, :to)
                 @criteria_value_hash[:ship_date][:to].to_date
               else
                 nil
               end

    order_owner_id = if @criteria_value_hash.dig(:order_owner_id)
                       @criteria_value_hash[:order_owner_id]
                     else
                       nil
                     end

    # order_costs =Order.joins('LEFT JOIN order_products ON order_products.order_id = orders.id').select('orders.order_id,order_products.product_cost,order_products.shipment_cost,order_products.discount,order_products.total_cost,order_products.receipt_date').order(:id, 'orders.order_id')
    order_payments =
      Order.normal_order
           .joins('LEFT JOIN order_payments ON order_payments.order_id = orders.id')
           .select('orders.order_id,
                    order_payments.payment_method,
                    order_payments.paid_amount,
                    order_payments.paid_date')
           .order(:id, 'orders.order_id')

    if start_date.present? && end_date.present?
      # order_costs.where('orders.order_created_at BETWEEN :from AND :to',from: @start_date.beginning_of_day.utc, to: @end_date.end_of_day.utc)
      order_payments =
        order_payments.where('orders.ship_date BETWEEN :from AND :to',
                             from: start_date.beginning_of_day.utc,
                             to: end_date.end_of_day.utc)
    end

    if order_owner_id.present?
      order_payments =
        order_payments.where('order_owners.id': order_owner_id)
    end

    case format
    when 'html'
      # TODO: show result in html
    when 'csv', 'tsv', 'xlsx'
      order_payments.each do |order_payment|
        hash = {}
        OrderSalesExport.export(order_payment).each_with_index do |element, index|
          hash[header[index]] = element
        end
        result << hash
      end
      cols_data_type = OrderSalesExport.cols_data_type
      cols_style = OrderSalesExport.cols_style
      # return ReportResult.new(data: result, headers: header, cols_data_type: cols_data_type, format: format, report: self)
      return ReportResult.new(data: result, headers: header, cols_data_type: cols_data_type, cols_style: cols_style, format: format, report: self)
    end
  end

  # Define criteria for the report
  def define_criteria(criteria)
    criteria.add_criterion(ReportCriterionDefinition.new(code: :order_owner_id, type: :enum_default_blank, enum: OrderOwner.all, enum_object_display_field: :order_code_prefix, model: OrderOwner, view_code: :order_code_prefix))
    criteria.add_criterion(ReportCriterionDefinition.new(code: :ship_date, type: :date_range_default_blank, model: Order, view_code: :ship_date))
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
                                        bg_color: 'D6DCE4',
                                        sz: 12,
                                        border: Axlsx::STYLE_THIN_BORDER,
                                        alignment: { horizontal: :center, vertical: :center, wrap_text: true }),

      # header
      header: worksheet.styles.add_style(font_name: '游ゴシック',
                                         bg_color: 'D6DCE4',
                                         sz: 12,
                                         border: Axlsx::STYLE_THIN_BORDER,
                                         alignment: { horizontal: :center, vertical: :center, wrap_text: true }),

      # text
      text: worksheet.styles.add_style(font_name: '游ゴシック',
                                       bg_color: 'D6DCE4',
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
        order_sale: {
          merge_cell_size: "A1:D2",
          merge_cell_data: [I18n.t(:'reports.order_sales_export.order_sales_report_title'), "", "", ""]
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
  class OrderSalesExport
    ###########################################################################
    # CONSTANT
    ###########################################################################
    FIELDS = %i[order_id payment_method paid_amount paid_date]
    FIELD_MAPS = {
      order_id: { type: :field, display: Order.human_attribute_name(:order_id) },
      payment_method: { type: :field, display: OrderPayment.human_attribute_name(:payment_method) },
      paid_amount: { type: :field, display: OrderPayment.human_attribute_name(:paid_amount), col_data_type: :integer },
      paid_date: { type: :date, display: OrderProduct.human_attribute_name(:receipt_date), col_data_type: :date }
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

    def self.export(order_payment)
      result = []

      FIELDS.collect do |field|
        case FIELD_MAPS[field][:type]
        when :field
          result << order_payment[field]
          # order_cost[field]
        when :date
          # TODO: change the time format to '%Y-%m-%d %H:%M' ?
          result << (order_payment[field].present? ? order_payment[field].in_time_zone('Japan').strftime('%Y/%m/%d') : nil)
        end
      end
      result
    end
  end
end