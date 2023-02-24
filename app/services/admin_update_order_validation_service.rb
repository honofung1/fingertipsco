class AdminUpdateOrderValidationService
  attr_reader :admin, :order

  def initialize(admin, order)
    @admin = admin
    @order = order
  end

  # TODO: Validation Explaination
  def validate
    return true if skip_validation

    can_update_order_product_price?
  end

  private

  def can_update_order_product_price?
    return senior_role_order_update_rule if @admin.super_admin?
    return junior_role_order_update_rule if @admin.admin?

    # default to false
    # but will not reach to this fallback normally
    false
  end

  # can exapnd later when new admin role add on
  def junior_role_order_update_rule
    return false if %w[shipped printed].include?(@order.state) && @order.will_save_change_to_total_price?

    # %w[prepaided received].include?(@order.state) && @order.will_save_change_to_total_price?
    true
  end

  def senior_role_order_update_rule
    true
  end

  # normal order type always pass the validation
  def skip_validation
    @order.order_type == "normal"
  end
end
