class AddReceivedToOrderProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :order_products, :received, :boolean
  end
end
