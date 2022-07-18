class Order < ApplicationRecord
  #############################################################################
  # Constant
  #############################################################################

  # TODO: change state to state_machine
  # state_machine :state, initial: :notpaid do
  #   state :notpaid
  #   state :paidpartly
  #   state :fullpaid
  #   state :finished
  #   state :cancelled
  # end
  # STATES = %w[notpaid paidpartly fullpaid finished cancelled].freeze

  # USING ENUM to define the state of order for now
  # notpaid    --> 0
  # paidpartly --> 1
  # fullpaid   --> 2
  # cancelled  --> 3
  # finished   --> 4
  #
  # State defination
  #  |State|            |Defination|
  #  notpaid            order is not have any payment yet, this is the default state of order
  #  paidpartly         order have payment, but not a full paid
  #  fullpaid           order have fullpaided, order balance should be 0 in this state
  #  cancelled          order cancelled
  #  finished           order finished
  enum state: [:notpaid, :paidpartly, :fullpaid, :cancelled, :finished]

  # set the default order code if the order doesn't have the order owner
  DEFAULT_ORDER_CODE_PREFIX = "FT".freeze
  PICKUP_WAYS = %w[TP S].freeze

  #############################################################################
  # Association
  #############################################################################
  belongs_to :order_owner

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
  validate :order_owner_id_cannot_changed

  #############################################################################
  # Callback
  #############################################################################

  before_create :ensure_order_created_at

  before_save :ensure_order_finished_at

  before_save :ensure_order_owner
  before_save :ensure_order_id

  #############################################################################
  # Method
  #############################################################################

  # Temp method
  # STATES.each do |state|
  #   define_method("#{state}?") do
  #     self.state == state
  #   end

  #   define_method("#{state}!") do
  #     self.update_attribute(:state, state)
  #   end
  # end

  def order_balance_with_hkd
    # total price => when order product updated his cost, auto update the field
    # so do this here

    self.total_price ||= 0
    "HKD$ #{self.total_price - order_total_paid_amount}"
  end

  def ensure_order_created_at
    self.order_created_at = Time.now
  end

  def ensure_order_finished_at
    return unless finished?

    self.order_finished_at = Time.now
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

  # auto gen order_id
  def reset_order_id
    order_id_code = order_owner_code

    order_id_ordering = order_owner.present? ? order_owner.orders.count : Random.rand(1...100)
    "#{order_id_code}#{Time.now.month}#{order_id_ordering.to_s.rjust(3, '0')}"
  end

  # get order_products attributes
  # eg. product_name
  def get_order_products_attr(product_attr)
    return nil unless OrderProduct.column_names.include?(product_attr)

    order_products_attrs = []

    order_products.each do |p|
      order_products_attrs << p.send("#{product_attr}")
    end

    # remove empty strings
    order_products_attrs = order_products_attrs.reject(&:empty?)

    # TODO: i18n or translate
    if order_products_attrs.empty?
      "-"
    else
      # order_products_attrs.join('/')
      order_products_attrs.count == 1 ? "#{order_products_attrs.first}": "#{order_products_attrs.first}以及其他#{order_products_attrs.count - 1}樣資料"
    end
  end

  def order_total_paid_amount
    total_paid_amount = 0

    order_payments.each do |p|
      total_paid_amount += p.paid_amount
    end

    total_paid_amount
  end

  def calculate_order_total_price
    total_price = 0

    order_products.each do |p|
      total_price += p.product_quantity * p.product_price
    end

    self.update_columns(total_price: total_price)
  end

  #############################################################################
  # Private Method
  #############################################################################
  private

  # if the record is persisted(already in db), not able to changed the orde_owner_id
  def order_owner_id_cannot_changed
    if order_owner_id_changed? && self.persisted?
      errors.add(:orde_owner_id, "Changed og Order Owner is not allowed!") # TODO: I18n
    end
  end

end
