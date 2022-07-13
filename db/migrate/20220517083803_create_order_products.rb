class CreateOrderProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :order_products do |t|
      t.integer :order_id, null: false
      t.string :shop_from           # 店
      t.string :product_name        # 商品名
      t.text :product_remark        # 配送用商品名
      t.integer :product_quantity   # 数量
      t.integer :product_price      # 単価

      # Order Shipment
      t.string :receive_number      # 受け取り番号
      t.string :hk_tracking_number  # 香港配送追跡番号
      t.string :tracking_number     # 国際追跡番号
      t.integer :state, default: 0  # using enum to define the state
      t.datetime :ship_date

      # Order Cost
      t.integer :product_cost       # 単価(税込)
      t.integer :shipment_cost      # 送料
      t.integer :discount           # 割引
      t.integer :total_cost         # 合計
      t.datetime :receipt_date      # 領收書日期

      t.timestamps
    end

    add_index :order_products, :order_id
    add_index :order_products, :ship_date
    add_index :order_products, :hk_tracking_number
    # add_index :order_products, :order_shipment_id
  end
end
