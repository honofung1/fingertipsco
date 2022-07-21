class MigrateDataToOrderOwnersOrderTotalCount < ActiveRecord::Migration[5.2]
  def change
    OrderOwner.all.each do |owner|
      order_total_c = owner.orders.count
      owner.order_total_count = order_total_c
      owner.save!
    end
  end
end
