class CreateOrderProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :order_products do |t|
      t.integer :order_id, null: false
      t.string :shop_from
      t.string :product_name
      t.string :product_remark
      t.integer :prodcut_amount
      t.integer :product_price
      t.integer :order_shipment_id

      t.timestamps
    end

    add_index :order_products, :order_id
    add_index :order_products, :order_shipment_id
  end
end
