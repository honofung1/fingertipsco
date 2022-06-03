class CreateOrderCosts < ActiveRecord::Migration[5.2]
  def change
    create_table :order_costs do |t|
      t.integer :order_id, null: false
      t.integer :product_id, null: false
      t.integer :product_cost
      t.integer :shipment_cost
      t.integer :discount
      t.integer :total_cost
      t.datetime :receipt_date

      t.timestamps
    end

    # TODO: add index for speed up query depends on use cases
    add_index :order_costs, :order_id
  end
end
