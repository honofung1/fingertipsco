class Order < ApplicationRecord  
  #############################################################################
  # Attribute
  #############################################################################
  attribute :total_price, :integer, default: 0
  # attribute :additional_fee, :integer, default: 0

  #############################################################################
  # Constant
  #############################################################################
  extend Enumerize

  # TODO: change state to state_machine
  # state_machine :state, initial: :notpaid do
  #   state :notpaid
  #   state :paidpartly
  #   state :fullpaid
  #   state :finished
  #   state :accounted
  #   state :cancelled
  # end

  # Order type
  # -------------------------------------------------------------------------------|
  # |    Order Type     |                      Description                         |
  # -------------------------------------------------------------------------------|
  # |       normal      |         counting the order total price only              |
  # -------------------------------------------------------------------------------|
  # |       prepaid     |         subtract the order owner balance                 |
  # -------------------------------------------------------------------------------|
  ORDER_TYPES = [
    ORDER_TYPE_NORMAL  = 'normal',
    ORDER_TYPE_PREPAID = 'prepaid'
  ].freeze

  # Additional fee type
  # -------------------------------------------------------------------------------|
  # |    Order Type       |                      Description                       |
  # -------------------------------------------------------------------------------|
  # |       fixed_value   |         a fixed amount for a order                     |
  # -------------------------------------------------------------------------------|
  # |       discount      |         a percentage discount for a order              |
  # -------------------------------------------------------------------------------|
  ADDITIONAL_FEE_TYPES = [
    ADDITIONAL_FEE_TYPE_FIXED = 'fixed_value',
    ADDITIONAL_FEE_TYPE_PER   = 'discount'
  ].freeze

  enumerize :order_type, in: ORDER_TYPES, predicates: { prefix: true }, scope: true
  enumerize :additional_fee_type, in: ADDITIONAL_FEE_TYPES, predicates: { prefix: true }, scope: true

  #  Order tx column explaination
  #  |Column Name|    |Explanation|
  #  xxxx_amount      The calculated tax amount, those columns will be added to order total price
  #  xxxx_fee         The original tax amount, those columns will used to calculate xxxx_amount and WILL NOT added to order total price
  #  xxxx_fee_type    The type of the xxxx_fee

  #  State defination FOR NORMAL TYPE ORDER
  #  |State|            |Defination|
  #  notpaid            order is not have any payment yet, this is the default state of order
  #  paidpartly         order have payment, but not a full paid
  #  fullpaid           order have fullpaided, order balance should be 0 in this state
  #  finished           order finished, but not yet proceed the accounting
  #  accounted          order finished and finish the accounting
  #  cancelled          order cancelled and should be ignore it

  #  State defination FOR PREPAID TYPE ORDER
  #  |State|            |Defination|
  #  prepaided          due to this order type is prepaid, the order creation will start in fullpaid
  #  shipped            same as normal order type finished
  #  printed            same as normal order type acounted

  #  |State|            |ENUM state code|          |Show in Website|
  #  notpaid                    0                        未付款
  #  paidpartly                 1                        有尾數
  #  fullpaid                   2                        已付全數
  #  finished                   3                        完成交易
  #  accounted                  4                        完成會計
  #  cancelled                  5                        已取消

  #  prepaided                  6                        已付款
  #  received                   7                        已收貨
  #  shipped                    8                        已寄出
  #  printed                    9                        已會計

  enum state: [:notpaid, :paidpartly, :fullpaid, :finished, :accounted, :cancelled, :prepaided, :received, :shipped, :printed]

  # set the default order code if the order doesn't have the order owner
  DEFAULT_ORDER_CODE_PREFIX = "DEF".freeze

  # This is the order product pickup ways
  # Now we have two types of pickup ways TP AND S
  # It is possible to add the pickup way later
  # TODO: let the pickup way modelize
  PICKUP_WAYS = %w[TP S].freeze

  # Order cuurency HKD AND JPY
  CURRENCYS = %w[HKD JPY].freeze

  # normal order defination
  NORMAL_ORDER_STATE = %w[notpaid paidpartly fullpaid finished accounted cancelled].freeze

  # prepaid order defination
  PREPAID_ORDER_STATE = %w[prepaided received shipped printed].freeze

  ##############################################################################
  # Extension
  ##############################################################################
  has_paper_trail

  #############################################################################
  # Association
  #############################################################################
  belongs_to :order_owner, autosave: true

  has_many :order_products, dependent: :destroy, inverse_of: :order
  accepts_nested_attributes_for :order_products, reject_if: :all_blank, allow_destroy: true

  has_many :order_payments, dependent: :destroy
  accepts_nested_attributes_for :order_payments, reject_if: :all_blank, allow_destroy: true

  # Temp to remove it
  # has_many :order_costs, dependent: :destroy
  # accepts_nested_attributes_for :order_costs, reject_if: :all_blank, allow_destroy: true

  # Temp to remove it
  # has_many :order_product_shipments, dependent: :destroy

  #############################################################################
  # Validation
  #############################################################################
  validates :order_owner_id, presence: true
  validates :order_type,     presence: true
  validates :currency, inclusion: { in: CURRENCYS }
  validates :pickup_way, inclusion: { in: PICKUP_WAYS }

  validates :additional_fee,      presence: true, if: :additional_fee_type?
  validates :additional_fee_type, presence: true, if: :additional_fee?

  validates :state, inclusion: { in: NORMAL_ORDER_STATE }, if: :is_normal?
  validates :state, inclusion: { in: PREPAID_ORDER_STATE }, if: :is_prepaid?

  validate :order_owner_id_cannot_changed
  validate :check_state_condition

  validate :validate_prepaid_order_proudct, if: :is_prepaid?
  validate :validate_prepaid_order_payment, if: :is_prepaid?
  validate :prevent_prepaid_order_product_delete, if: :is_prepaid?
  # validate :validate_order_owner_have_enough_quota, if: :is_prepaid?
  # validate :prepaid_order_cannot_modify_product, if: :is_prepaid?
  # validate :prepaid_order_cannot_change_additional_fee, if: :is_prepaid?
  # validate :prepaid_order_cannot_change_additional_fee_type, if: :is_prepaid?

  validate :validate_normal_order_handling_amount,   if: :is_normal?
  validate :validate_normal_order_additional_amount, if: :is_normal?

  #############################################################################
  # Callback
  #############################################################################
  before_create :ensure_order_created_at

  after_create :order_owner_count_increment
  # after_create :deduct_balacne_from_order_owner, if: :is_prepaid?

  before_save :ensure_order_finished_at, if: :will_save_change_to_state?
  before_save :ensure_order_owner
  before_save :ensure_order_id

  after_save :recalculate_order_owner_balance, if: :is_prepaid?

  after_destroy :return_balance_to_order_owner, if: :is_prepaid?

  ##############################################################################
  # Scope
  ##############################################################################

  scope :prepaid_order, -> { where(order_type: ORDER_TYPE_PREPAID) }
  scope :normal_order, -> { where(order_type: ORDER_TYPE_NORMAL) }

  #############################################################################
  # Method
  #############################################################################

  # Self define a method for order type
  ORDER_TYPES.each do |this_order_type|
    define_method "is_#{this_order_type}?" do
      self.order_type == this_order_type
    end
  end

  # Overwrite the setter to rely on validations instead of [ArgumentError]
  # https://github.com/rails/rails/issues/13971
  def state=(value)
    self[:state] = value
  rescue ArgumentError
    self[:state] = nil
  end

  # This is for normal order now
  # cause prepaid prder cannot change or update order product
  # 20230223 TODO: merge with prepaid order way
  def calculate_order_total_price
    return unless is_normal?

    total_price = 0

    # Check this
    order_products.reload.each do |p|
      total_price += p.product_quantity * p.product_price
    end

    self.update_columns(total_price: total_price)
  end

  # HKD and JPY should have different dollar sign
  # Two use case for now (HKD and JPY)
  # TODO: REFACTOR
  def curreny_with_sign
    dollar_sign = currency == "HKD" ? "$" : "¥"
    "#{currency} #{dollar_sign}"
  end

  def clone_order
    self.deep_clone include: [:order_products]
  end

  def ensure_order_created_at
    self.order_created_at = Time.now
  end

  def ensure_order_finished_at
    return unless finished? || printed?

    self.order_finished_at = Time.now
  end

  # def deduct_balacne_from_order_owner
  #   new_balance = order_owner.balance - self.total_price
  #   order_owner.update_columns(balance: new_balance)
  #   order_owner.update_attributes(balance: new_balance)
  # end

  def recalculate_order_owner_balance
    return if self.total_price.nil? || self.total_price == 0
    return unless saved_change_to_total_price?

    # Order new create situation
    before_total_price = total_price_before_last_save || 0
    new_total_price = self.total_price

    new_balance = order_owner.balance + before_total_price - new_total_price

    order_owner.update_attributes!(balance: new_balance)
  end

  def return_balance_to_order_owner
    return if self.total_price.nil? || self.total_price == 0

    new_balance = order_owner.balance + self.total_price

    order_owner.update_attributes!(balance: new_balance)
  end

  def order_owner_code
    order_owner.order_code_prefix ||= DEFAULT_ORDER_CODE_PREFIX
  end

  def ensure_order_owner
    false if order_owner.blank?
  end

  def ensure_order_id
    if order_id.blank?
      self.order_id = reset_order_id
    end
  end

  # auto generate order_id
  # order_id generate pattern
  # Order Channel + year and mouth which is order created without ceuntry + Order Owner total count orders
  def reset_order_id
    order_id_code = order_owner_code

    order_id_ordering = order_owner.present? ? order_owner.order_total_count + 1 : Random.rand(1...1000)
    # Using Time.now.strftime('%y') instead of Time.now.year % 100 to get the year without ceuntry
    "#{order_id_code}#{Time.now.strftime('%y%m')}#{order_id_ordering.to_s.rjust(4, '0')}"
  end

  # For Admin page usage
  # get order_products attributes
  # eg. product_name
  def get_order_products_attr(product_attr)
    return nil unless OrderProduct.column_names.include?(product_attr)

    order_products_attrs = []

    order_products.each do |p|
      # order_products_attrs << p.send("#{product_attr}")
      attr_value = p.send(product_attr)
      next if attr_value.nil?

      attr_value = attr_value.strftime("%Y-%m-%d") if product_attr == "ship_date"

      order_products_attrs << attr_value
    end

    # remove empty strings
    order_products_attrs = order_products_attrs.reject(&:empty?)

    # TODO: i18n or translate
    if order_products_attrs.empty?
      " "
    else
      # order_products_attrs.join('/')
      order_products_attrs.count == 1 ? "#{order_products_attrs.first}": "#{order_products_attrs.first}和#{order_products_attrs.count - 1}樣資料"
    end
  end

  def order_total_paid_amount
    total_paid_amount = 0

    # Remove the nil paid amount order payment record
    has_payment = order_payments.reject { |p| p.paid_amount.nil? }

    has_payment.each do |p|
      total_paid_amount += p.paid_amount
    end

    total_paid_amount
  end

  def order_balance
    order_total_paid_amount - self.total_price
  end

  def order_balance_with_dollar_sign
    # order_total_paid_amount => refer the method
    # total price => when order product updated his product price, auto update the field
    # so do this here

    # Set the total_price to 0 when the order not have products yet
    self.total_price ||= 0
    "#{curreny_with_sign}#{order_balance}"
  end

  # After create the order, call the order owner method to count the order totals which is the order
  # numbers he owns
  def order_owner_count_increment
    order_owner.add_order_count
  end

  #############################################################################
  # Private Method
  #############################################################################
  private

  def additional_fee?
    additional_fee.present?
  end

  def additional_fee_type?
    additional_fee_type.present?
  end

  # if the record is persisted(already in db), not able to changed the order_owner_id
  def order_owner_id_cannot_changed
    if order_owner_id_changed? && self.persisted?
      errors.add(:order_owner_id, I18n.t(:'errors.order.cannot_modify'))
    end
  end

  def check_state_condition
    return unless state_changed?

    ##############################################################################
    # normal order state
    ##############################################################################
    if fullpaid? && order_payments.blank?
      state_error_call(state, I18n.t(:'errors.order.order_payments_blank'))
    end

    if finished? && ship_date.nil?
      state_error_call(state, I18n.t(:'errors.order.ship_date_blank'))
    end

    if finished? && order_balance < 0
      state_error_call(state, I18n.t(:'errors.order.order_balance_not_zero'))
    end

    # if accounted? && order_products.where("receipt_date IS NULL").count > 0
    # cannot use 'where' here due to not save to db yet so that cannot find
    # out which receipt_date is null

    # if accounted? && order_products.filter(&:receipt_date?).blank?
    if accounted? && order_products.filter(&:receipt_date?).count != order_products.count
      state_error_call(state, I18n.t(:'errors.order.receipt_date_blank'))
    end

    ##############################################################################
    # prepaid order state
    ##############################################################################
    if shipped? && ship_date.nil?
      state_error_call(state, I18n.t(:'errors.order.ship_date_blank'))
    end

    if printed? && order_products.filter(&:receipt_date?).blank?
      return if order_products.blank?

      state_error_call(state, I18n.t(:'errors.order.receipt_date_blank'))
    end
  end

  def state_error_call(status, error_msg)
    errors.add(:state, I18n.t(:'message.state_update_failed', state: I18n.t(:"enums.order.#{status}"), error: error_msg))
  end

  # limit prepaid order type product should always 1
  # TODO: move out of the model
  def validate_prepaid_order_proudct
    if order_products.size > 1
      errors.add(:order_products, I18n.t(:'errors.order.over_limit'))
    end
  end

  # def prepaid_order_cannot_modify_product
  #   return if order_products.blank?

  #   prepaid_order_product = order_products.first

  #   # must be order_products.first due to there has one product only
  #   if persisted? && prepaid_order_product.has_changes_to_save?
  #     errors.add(:order_products, I18n.t(:'errors.order.cannot_modify'))
  #   end
  # end

  def prevent_prepaid_order_product_delete
    return if order_products.blank?

    errors.add(:order_products, I18n.t(:'errors.order.cannot_delete')) if persisted? && order_products.first.marked_for_destruction?
  end

  # def prepaid_order_cannot_change_additional_fee
  #   return unless persisted?
  #   return unless will_save_change_to_additional_fee?

  #   errors.add(:additional_fee, I18n.t(:'errors.order.cannot_modify'))
  # end

  # def prepaid_order_cannot_change_additional_fee_type
  #   return unless persisted?
  #   return unless will_save_change_to_additional_fee_type?

  #   errors.add(:additional_fee_type, I18n.t(:'errors.order.cannot_modify'))
  # end

  # avoid prepaid order type own order payment
  def validate_prepaid_order_payment
    errors.add(:order_payments, I18n.t(:'errors.order.cannot_own')) unless order_payments.empty?
  end

  # 2023/01/27
  # comment out for now due to this use case is not suitable for now
  # def validate_order_owner_have_enough_quota
  #   if order_owner.balance - self.total_price < 0
  #     errors.add(:order_owners, "餘額不足以建立訂單")
  #   end
  # end

  def validate_normal_order_handling_amount
    # prevent previous order occur error when they don't have handling_amount
    return if handling_amount.nil?

    errors.add(:handling_amount, I18n.t(:'errors.order.cannot_own')) if handling_amount > 0
  end

  def validate_normal_order_additional_amount
    # prevent previous order occur error when they don't have additional_amount
    return if additional_amount.nil?

    errors.add(:additional_amount, I18n.t(:'errors.order.cannot_own')) if additional_amount > 0
  end
end
