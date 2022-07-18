class MigrateUserdatasDataToAdminUsers < ActiveRecord::Migration[5.2]
  def up
    # results = ActiveRecord::Base.connection.exec_query("SELECT * FROM USERDATA;")

    # results.each do |result|
    #   Admin.create!(
    #     name: result["name"],
    #     username: result["username"],
    #     password: result["password"],
    #     password_confirmation: result["password"]
    #   )
    # end
  end

  def down
    # Doing nothing
  end
end
