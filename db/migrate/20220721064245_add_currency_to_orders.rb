class AddCurrencyToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :currency, :string
    add_index :orders, :currency
  end
end
