class CreateOrderProductShipments < ActiveRecord::Migration[5.2]
  def change
    # create_table :shipments do |t|
    #   t.integer :order_id
    #   t.string :receive_number     # 受け取り番号
    #   t.string :hk_tracking_number # 香港配送追跡番号
    #   t.string :tracking_number    # 国際追跡番号
    #   t.string :state
    #   t.datetime :ship_date

    #   t.timestamps
    # end

    # add_index :order_product_shipments, :order_id
    # TODO: add index for query speed depend on use cases
  end
end

# TODO: refactor order -> shipment -> order_products relationship
