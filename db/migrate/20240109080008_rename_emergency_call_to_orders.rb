class RenameEmergencyCallToOrders < ActiveRecord::Migration[6.1]
  def change
    rename_column :orders, :emergency_call, :ready_to_ship
  end
end
