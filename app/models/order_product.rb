class OrderProduct < ApplicationRecord
  #############################################################################
  # Constant
  #############################################################################

  # REFERENCE TO OrderProduct MIGRATION
  # enum state: [:notpaid, :paidpartly, :fullpaid, :finished, :cancelled]

  #############################################################################
  # Association
  #############################################################################
  belongs_to :order, inverse_of: :order_products

  has_one :order_product_shipment
  #############################################################################
  # Validation
  #############################################################################

  # 2022/09/01 temp to remove the product_quanitity and product price validation due to kylie requested
  # validates :product_quantity, presence: true, numericality: { greater_than: 0 }
  # validates :product_price, presence: true, numericality: { greater_than: 0 }

  #############################################################################
  # Callback
  #############################################################################

  after_save :update_order_total_price
  after_destroy :update_order_total_price

  #############################################################################
  # Method
  #############################################################################

  def update_order_total_price
    # prevent the updating the order total price all the time when
    # update the order poduct other informarion
    return unless saved_change_to_product_quantity? || saved_change_to_product_price?

    order.calculate_order_total_price
  end
  #############################################################################
  # Private Method
  #############################################################################
end
