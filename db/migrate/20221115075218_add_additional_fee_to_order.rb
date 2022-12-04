class AddAdditionalFeeToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :additional_fee, :integer
    add_column :orders, :additional_fee_type, :string
    add_column :orders, :additional_amount, :integer
    add_column :orders, :handling_amount, :integer
    add_column :orders, :order_type, :string
  end
end
