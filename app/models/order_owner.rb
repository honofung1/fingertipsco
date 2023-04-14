class OrderOwner < ApplicationRecord
  #############################################################################
  # Constant
  #############################################################################

  #############################################################################
  # Extension
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

  has_one :order_owner_account, dependent: :destroy, inverse_of: :order_owner
  accepts_nested_attributes_for :order_owner_account, reject_if: :all_blank, allow_destroy: true

  #############################################################################
  # Validation
  #############################################################################
  validates :name, presence: true
  validates :order_code_prefix, uniqueness: true, presence: true

  validates :handling_fee,               numericality: true, allow_nil: true

  validates :minimum_consumption_amount, numericality: true, allow_nil: true
  validates :minimum_handling_fee,       numericality: true, allow_nil: true

  validates :minimum_consumption_amount, :minimum_handling_fee, presence: true, if: :enable_minimum_consumption

  validates :maximum_consumption_amount, numericality: true, allow_nil: true
  validates :maximum_handling_fee,       numericality: true, allow_nil: true

  validates :maximum_consumption_amount, :maximum_handling_fee, presence: true, if: :enable_maximum_consumption

  validate :not_allow_to_own_handling_fee

  validate :not_allow_to_own_minimum_consumption_amount
  validate :not_allow_to_own_minimum_handling_fee
  validate :not_allow_to_own_enable_minimum_consumption

  validate :not_allow_to_own_maximum_consumption_amount
  validate :not_allow_to_own_maximum_handling_fee
  validate :not_allow_to_own_enable_maximum_consumption
  # validates :balance, numericality: { greater_than_or_equal_to: 0 }

  #############################################################################
  # Callback
  #############################################################################

  before_destroy :unable_to_destroy_order_owner
  #############################################################################
  # Method
  #############################################################################

  def email_account
    order_owner_account.present? ? order_owner_account.email : nil
  end

  def send_balance_notification
    BalanceMailer.balance_notification(self).deliver_now
  end

  def need_to_send_balance_notification?
    if self.balance_limit.present?
      return self.balance < self.balance_limit
    end

    self.balance < 0
  end

  # count + 1 when the order is successfully created.
  def add_order_count
    # TODO: can add multiple numbers order but not use case for now
    order_total_count = self.order_total_count + 1

    self.update_columns(order_total_count: order_total_count)
  end

  def reset_order_count
    self.update_columns(order_total_count: 0)
  end

  def key_account?
    SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes').include?(order_code_prefix)
  end

  def avatar_url
    # TODO: temp method
    # Path app/assets/images/avatar2.png
    "avatar5.png"
  end

  def order_owner_ability
    @order_owner_ability ||= OrderOwnerAbility.new(self)
  end

  delegate :can?, :cannot?, to: :order_owner_ability
  #############################################################################
  # Private Method
  #############################################################################

  private

  def not_allow_to_own_handling_fee
    return if SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes').include?(order_code_prefix)

    if handling_fee.present?
      errors.add(:handling_fee, I18n.t(:'errors.order_owner.must_be_blank'))
    end
  end

  def not_allow_to_own_minimum_consumption_amount
    return if SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes').include?(order_code_prefix)

    if minimum_consumption_amount.present?
      errors.add(:minimum_consumption_amount, I18n.t(:'errors.order_owner.must_be_blank'))
    end
  end

  def not_allow_to_own_minimum_handling_fee
    return if SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes').include?(order_code_prefix)

    if minimum_handling_fee.present?
      errors.add(:minimum_handling_fee, I18n.t(:'errors.order_owner.must_be_blank'))
    end
  end

  def not_allow_to_own_enable_minimum_consumption
    return if SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes').include?(order_code_prefix)

    if enable_minimum_consumption.present?
      errors.add(:enable_minimum_consumption, I18n.t(:'errors.order_owner.must_be_blank'))
    end
  end

  def not_allow_to_own_maximum_consumption_amount
    return if SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes').include?(order_code_prefix)

    if maximum_consumption_amount.present?
      errors.add(:maximum_consumption_amount, I18n.t(:'errors.order_owner.must_be_blank'))
    end
  end

  def not_allow_to_own_maximum_handling_fee
    return if SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes').include?(order_code_prefix)

    if maximum_handling_fee.present?
      errors.add(:maximum_handling_fee, I18n.t(:'errors.order_owner.must_be_blank'))
    end
  end

  def not_allow_to_own_enable_maximum_consumption
    return if SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes').include?(order_code_prefix)

    if enable_maximum_consumption.present?
      errors.add(:enable_maximum_consumption, I18n.t(:'errors.order_owner.must_be_blank'))
    end
  end

  def unable_to_destroy_order_owner
    errors.add(:base, I18n.t(:'errors.order_owner.cannot_delete')) if orders.count > 0
  end
end
