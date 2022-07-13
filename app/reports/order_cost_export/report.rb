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
      # return result
      return ReportResult.new(data: result, headers: header, cols_data_type: cols_data_type, format: format, report: self)
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
      product_cost: { type: :field, display: OrderProduct.human_attribute_name(:product_cost) },
      shipment_cost: { type: :field, display: OrderProduct.human_attribute_name(:shipment_cost) },
      discount: { type: :field, display: OrderProduct.human_attribute_name(:discount) },
      total_cost: { type: :field, display: OrderProduct.human_attribute_name(:total_cost) },
      receipt_date: { type: :date, display: OrderProduct.human_attribute_name(:receipt_date) }
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

    def self.export(order_cost)
      result = []

      FIELDS.collect do |field|
        case FIELD_MAPS[field][:type]
        when :field
          result << order_cost[field]
          # order_cost[field]
        when :date
          # TODO: change the time format to '%Y-%m-%d %H:%M' ?
          result << (order_cost[field].present? ? order_cost[field].in_time_zone('Japan').strftime('%Y-%m-%d') : nil)
        end
      end
      result
    end
  end
end
