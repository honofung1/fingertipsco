class OrderOwner < ApplicationRecord
  #############################################################################
  # Constant
  #############################################################################

  #############################################################################
  #############################################################################
  has_paper_trail

  #############################################################################
  # Scope
  #############################################################################

  scope :not_key_account, -> { where.not(order_code_prefix: SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes')) }

  scope :key_account, -> { where(order_code_prefix: SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes')) }
  #############################################################################
  # Association
  #############################################################################
  has_many :deposit_records, dependent: :restrict_with_error
  has_many :orders, dependent: :restrict_with_error

  #############################################################################
  # Validation
  #############################################################################
  validates :name, presence: true
  validates :order_code_prefix, uniqueness: true, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  #############################################################################
  # Callback
  #############################################################################

  before_destroy :unable_to_destroy_order_owner
  #############################################################################
  # Method
  #############################################################################

  # count + 1 when the order is successfully created.
  def add_order_count
    # TODO: can add multiple numbers order but not use case for now
    order_total_count = self.order_total_count + 1

    self.update_columns(order_total_count: order_total_count)
  end

  def reset_order_count
    self.update_columns(order_total_count: 0)
  end

  #############################################################################
  # Private Method
  #############################################################################
end
