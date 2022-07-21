class AddOrderTotalCountToOrderOwner < ActiveRecord::Migration[5.2]
  def change
    add_column :order_owners, :order_total_count, :integer, default: 0
  end
end
