class OrderOwner < ApplicationRecord
  #############################################################################
  # Constant
  #############################################################################

  #############################################################################
  # Association
  #############################################################################
  has_many :orders

  #############################################################################
  # Validation
  #############################################################################
  validates :name, presence: true
  validates :order_code_prefix, uniqueness: true, presence: true

  #############################################################################
  # Callback
  #############################################################################

  #############################################################################
  # Method
  #############################################################################

  # count + 1 when the order is successfully created.
  def add_order_count
    # TODO: can add multiple numbers order but not use case for now
    order_total_count = self.order_total_count + 1

    self.update_columns(order_total_count: order_total_count)
  end

  # TODO: create a monthly job to reset the order count to zero
  def reset_the_order_count
    self.update_columns(order_total_count: 0)
  end

  #############################################################################
  # Private Method
  #############################################################################
end
