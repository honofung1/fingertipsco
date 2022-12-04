class CreateDepositRecord < ActiveRecord::Migration[5.2]
  def change
    create_table :deposit_records do |t|
      t.integer :order_owner_id, null: false
      t.integer :deposit_amount, null: false
      t.datetime :deposit_date, null: false

      t.timestamps
    end
  end
end
