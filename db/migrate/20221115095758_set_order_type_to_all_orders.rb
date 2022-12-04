class SetOrderTypeToAllOrders < ActiveRecord::Migration[5.2]
  def change
    SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes').each do |c|
      order_owner = OrderOwner.find_by(order_code_prefix: c)
      next if order_owner.nil?

      Order.where(order_owner_id: order_owner.id).find_in_batches do |record_batch|
        Order.where(id: record_batch.map(&:id)).update_all(order_type: "prepaid")
      end
    end

    Order.where("order_type IS NULL").find_in_batches do |record_batch|
      Order.where(id: record_batch.map(&:id)).update_all(order_type: "normal")
    end
  end
end
