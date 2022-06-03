# which is creating table named order_owners
class CreateOrders < ActiveRecord::Migration[5.2]
  def change

    # TODO: add pay first amount for future function
    create_table :order_owners do |t|
      t.string :name, null: false
      t.string :order_code_prefix, null: false

      t.timestamps
    end

    # create_table :orders do |t|
    #   t.integer :order_id, unique: true
    #   t.integer :order_owner_id
    #   t.string :customer_name
    #   t.string :customer_contact
    #   t.string :customer_address
    # end

    # create_table :order_products do |t|

    # end

  end
end
