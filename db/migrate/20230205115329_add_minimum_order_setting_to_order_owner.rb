class AddMinimumOrderSettingToOrderOwner < ActiveRecord::Migration[5.2]
  def change
    add_column :order_owners, :minimum_consumption_amount, :integer
    add_column :order_owners, :minimum_handling_fee,       :integer
    add_column :order_owners, :maximum_consumption_amount, :integer
    add_column :order_owners, :maximum_handling_fee,       :integer
    add_column :order_owners, :enable_minimum_consumption, :boolean
    add_column :order_owners, :enable_maximum_consumption, :boolean
  end
end
