class AddColsToOrderOwner < ActiveRecord::Migration[5.2]
  def change
    add_column :order_owners, :addresses,      :string
    add_column :order_owners, :telephone,      :integer
    add_column :order_owners, :balance,        :integer, null: false, default: 0
    add_column :order_owners, :handling_fee,   :integer
  end
end
