class CreateSystemSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :system_settings do |t|
      t.string :name
      t.string :value
      t.string :value_type

      t.timestamps
    end
  end
end
