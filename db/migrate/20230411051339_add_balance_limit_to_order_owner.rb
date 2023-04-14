class AddBalanceLimitToOrderOwner < ActiveRecord::Migration[5.2]
  def change
    add_column :order_owners, :balance_limit, :integer
  end
end
