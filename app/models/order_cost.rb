class OrderCost < ApplicationRecord
  #############################################################################
  # Constant
  #############################################################################

  #############################################################################
  # Association
  #############################################################################
  belongs_to :order

  has_one :order_product
  #############################################################################
  # Validation
  #############################################################################

  #############################################################################
  # Callback
  #############################################################################

  #############################################################################
  # Method
  #############################################################################

  #############################################################################
  # Private Method
  #############################################################################
end
