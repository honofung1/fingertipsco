class AddShipmentColumnsToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :receive_number, :string
    add_column :orders, :hk_tracking_number, :string
    add_column :orders, :tracking_number, :string
    add_column :orders, :ship_date, :datetime

    # TODO: add the index if needed, such as using the ship_date to search the order
    # add_index :orders, :ship_date
    # add_index :orders, :hk_tracking_number
  end
end
