class DepositRecord < ApplicationRecord
  #############################################################################
  # Constant
  #############################################################################

  #############################################################################
  # Extension
  #############################################################################
  has_paper_trail

  #############################################################################
  # Association
  #############################################################################
  belongs_to :order_owner

  #############################################################################
  # Validation
  #############################################################################
  validates :deposit_amount, presence: true, numericality: { greater_than: 0 }
  validates :deposit_date, presence: true

  #############################################################################
  # Callback
  #############################################################################

  # Auto update the balance for some order owners
  counter_culture :order_owner, column_name: "balance", delta_column: "deposit_amount"

  #############################################################################
  # Method
  #############################################################################

  # ranasck method
  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at deposit_amount deposit_date id order_owner_id updated_at]
  end

  #############################################################################
  # Private Method
  #############################################################################
end
