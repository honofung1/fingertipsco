class CreateOrderPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :order_payments do |t|
      t.integer :order_id, null: false
      t.string :payment_method
      t.integer :paid_amount
      t.datetime :paid_date

      t.timestamps
    end

    add_index :order_payments, :order_id
  end
end
