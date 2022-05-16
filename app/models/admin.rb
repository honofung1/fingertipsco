class Admin < ApplicationRecord
  self.table_name = "admin_users"

  #############################################################################
  # Constant
  #############################################################################

  #############################################################################
  # Association
  #############################################################################

  #############################################################################
  # Validation
  #############################################################################
  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  #############################################################################
  # Callback
  #############################################################################

  #############################################################################
  # Method
  #############################################################################

  def avatar_url
    # TODO: temp method
    # Path app/assets/images/avatar2.png
    "avatar2.png"
  end

  # From https://github.com/Sorcery/sorcery/blob/master/lib/sorcery/model/submodules/reset_password.rb
  # def change_password(new_password, raise_on_failure: false)
  #   send("password=", new_password)
  #   # send(:"#{sorcery_config.password_attribute_name}=", new_password)
  #   sorcery_adapter.save raise_on_failure: raise_on_failure
  # end
  #############################################################################
  # Private Method
  #############################################################################
end
