class ChangeContactTypeToStringInOrderOwner < ActiveRecord::Migration[5.2]
  def change
    change_column :order_owners, :telephone, :string
  end
end
