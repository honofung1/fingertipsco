class OrderProduct < ApplicationRecord
  #############################################################################
  # Constant
  #############################################################################
  extend Enumerize

  enumerize :tax_type, in: { normal: 10, deduce: 8 }, predicates: { prefix: true }, scope: true

  # REFERENCE TO OrderProduct MIGRATION
  # enum state: [:notpaid, :paidpartly, :fullpaid, :finished, :cancelled]

  ##############################################################################
  # Extension
  ##############################################################################
  has_paper_trail

  #############################################################################
  # Association
  #############################################################################
  belongs_to :order, inverse_of: :order_products

  #############################################################################
  # Validation
  #############################################################################

  # 2022/09/01 temp to remove the product_quantity and product price validation due to kylie requested
  # validates :product_quantity, presence: true, numericality: { greater_than: 0 }
  validates :product_price, presence: true, numericality: { greater_than: -1 }

  #############################################################################
  # Callback
  #############################################################################

  after_save :update_order_total_price, if: -> { order.is_normal? }
  after_destroy :update_order_total_price, if: -> { order.is_normal? }

  #############################################################################
  # Method
  #############################################################################

  # ransack method
  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at discount hk_tracking_number id order_id product_cost
       product_name product_price product_quantity product_remark receipt_date receive_number
       received ship_date shipment_cost shop_from total_cost tracking_number updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[order versions]
  end

  #############################################################################
  # Private Method
  #############################################################################
  private

  def update_order_total_price
    # prevent the updating the order total price all the time when
    # update the order poduct other informarion
    # return unless saved_change_to_product_quantity? || saved_change_to_product_price?
    # TODO: call order calculation service

    order.calculate_order_total_price
  end
end
