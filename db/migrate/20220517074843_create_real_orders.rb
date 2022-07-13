# which is crearing tabla named orders
class CreateRealOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :order_id, unique: true
      t.integer :order_owner_id, null: false
      t.string :customer_name
      t.string :customer_contact
      t.string :customer_address
      t.integer :state, default: 0 # using enum to define the state
      t.integer :total_price
      t.datetime :order_created_at
      t.datetime :order_finished_at
      t.boolean :emergency_call, default: false
      t.string :pickup_way
      t.text :remark

      t.timestamps
    end

    add_index :orders, :order_id, unique: true
    add_index :orders, :order_owner_id
    add_index :orders, :state
    add_index :orders, %i[order_created_at order_finished_at], name: 'index_orders_on_created_finished'
  end
end
