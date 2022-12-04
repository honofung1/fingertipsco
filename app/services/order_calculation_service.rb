class OrderCalculationService
  attr_reader :order

  def initialize(order)
    # left : attr_reader's order
    # right: initialize(order)'s order
    @order = order
  end

  def call
    order_total_price = order_total_price_calculation

    if @order == Order::ORDER_TYPE_NORMAL
      @order.total_price = order_total_price
    else
      order_handling_tx = order_handling_tx_calculation(order_total_price_calculation) || 0
      order_price_with_handling_tx = order_total_price + order_handling_tx

      @order.handling_amount = order_handling_tx
      @order.total_price = order_price_with_handling_tx

      return @order unless need_cal_additional_fee?

      order_additional_tx = order_additional_tx_calculation(order_price_with_handling_tx) || 0

      @order.additional_amount = order_additional_tx

      order_total_price_with_all_tx = order_price_with_handling_tx + order_additional_tx

      @order.total_price = order_total_price_with_all_tx
    end

    @order
  end

  private

  #############################################################################
  # Order total price calculation
  #############################################################################
  # Step 1
  # calculate order products total amount
  #
  # Step 2
  # return the price if the order is normal type
  #
  # PREPAID TYPE Order calculation begin
  # Step 3
  # calculate order owner handling fee
  #
  # Step 4 (optional)
  # calculate order additional fee
  #############################################################################
  def order_total_price_calculation
    return if @order.order_products.nil?

    ops_total_price = 0

    @order.order_products.each do |p|
      ops_total_price += p.product_quantity * p.product_price
    end

    ops_total_price
  end

  # Order owner handling fee process
  # Returning the tax only
  def order_handling_tx_calculation(total_price)
    order_owner_handling_fee = @order.order_owner.handling_fee.to_f

    ops_total_price_handling_tx = total_price.to_f * order_owner_handling_fee / 100.0

    ops_total_price_handling_tx.round
  end

  # Order additional fee process
  # Returning the tax only
  def order_additional_tx_calculation(total_price)
    ops_total_price_additional_tx = if @order.additional_fee_type == Order::ADDITIONAL_FEE_TYPE_FIXED
                                      @order.additional_fee
                                    else
                                      total_price * @order.additional_fee / 100
                                    end

    ops_total_price_additional_tx.round
  end

  def need_cal_additional_fee?
    @order.additional_fee.present? && @order.additional_fee_type.present?
  end
end
