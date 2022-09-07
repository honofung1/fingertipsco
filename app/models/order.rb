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
  #   state :accounted
  #   state :cancelled
  # end

  # USING ENUM to define the state of order for now
  # notpaid      -->  0
  # paidpartly   -->  1
  # fullpaid     -->  2
  # finished     -->  3
  # accounted    -->  4
  # cancelled    -->  5
  #
  # State defination
  #  |State|            |Defination|
  #  notpaid            order is not have any payment yet, this is the default state of order
  #  paidpartly         order have payment, but not a full paid
  #  fullpaid           order have fullpaided, order balance should be 0 in this state
  #  finished           order finished, but not yet proceed the accounting
  #  accounted          order finished and finish the accounting
  #  cancelled          order cancelled and should be ignore it
  enum state: [:notpaid, :paidpartly, :fullpaid, :finished, :accounted, :cancelled]

  # set the default order code if the order doesn't have the order owner
  DEFAULT_ORDER_CODE_PREFIX = "DEF".freeze

  # This is the order product pickup ways
  # Now we have two types of pickup ways TP AND S
  # It is possible to add the pickup way later
  PICKUP_WAYS = %w[TP S].freeze

  # Order cuurency HKD AND JPY
  CURRENCYS = %w[HKD JPY].freeze

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
  validates :currency, inclusion: { in: CURRENCYS }
  validates :pickup_way, inclusion: { in: PICKUP_WAYS }

  validate :order_owner_id_cannot_changed

  #############################################################################
  # Callback
  #############################################################################

  before_create :ensure_order_created_at

  after_create :order_owner_count_increment

  before_save :ensure_order_finished_at
  before_save :ensure_order_owner
  before_save :ensure_order_id

  #############################################################################
  # Method
  #############################################################################

  def calculate_order_total_price
    total_price = 0

    order_products.each do |p|
      total_price += p.product_quantity * p.product_price
    end

    self.update_columns(total_price: total_price)
  end

  # HKD and JPY have different dollar sign
  def curreny_with_sign
    dollar_sign = currency == "HKD" ? "$" : "¥"
    "#{currency}#{dollar_sign}"
  end

  def clone_order
    self.deep_clone include: [ :order_products ]
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

    order_payments.each do |p|
      total_paid_amount += p.paid_amount
    end

    total_paid_amount
  end

  def order_balance
    # total price => when order product updated his product price, auto update the field
    # so do this here

    # Set the total_price to 0 when the order not have products yet
    self.total_price ||= 0
    "#{curreny_with_sign}#{order_total_paid_amount - self.total_price}"
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

  # if the record is persisted(already in db), not able to changed the order_owner_id
  def order_owner_id_cannot_changed
    if order_owner_id_changed? && self.persisted?
      errors.add(:order_owner_id, "Changed on Order Owner is not allowed!") # TODO: I18n
    end
  end

end
