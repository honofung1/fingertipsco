class MigrateShipmentDataFromOrderProductsToOrders < ActiveRecord::Migration[5.2]
  def change
    # Migrate the having order products orders data only
    # We are not touching the orders which is not have the order products
    Order.joins(:order_products).distinct.each do |o|
      order_product = o.order_products.first

      o.receive_number     = order_product.receive_number
      o.hk_tracking_number = order_product.hk_tracking_number
      o.tracking_number    = order_product.tracking_number
      o.ship_date          = order_product.ship_date

      o.save!
    end
  end
end
