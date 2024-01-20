class AddTaxTypeToOrderProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :order_products, :tax_type, :integer
  end
end
