# Which is Creating talbe named admin_users
class CreateAdmins < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_users do |t|
      t.string   :username, null: false
      t.string   :name, null: false
      t.string   :crypted_password
      t.string   :salt
      t.integer  :role, default: 0
      # reset password purpose
      t.string   :email
      t.string   :reset_password_token, default: nil
      t.string   :reset_password_token_expires_at, :datetime, default: nil
      t.string   :reset_password_email_sent_at, :datetime, default: nil
      t.integer  :access_count_to_reset_password_page, default: 0

      t.timestamps
    end

    add_index :admin_users, :username, unique: true
    add_index :admin_users, :reset_password_token
  end
end
