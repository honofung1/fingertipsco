class SetDefaultHkdCurrencyToOrder < ActiveRecord::Migration[5.2]
  def change
    Order.all.each do |o|
      o.currency = "HKD"
      o.save!
    end
  end
end
