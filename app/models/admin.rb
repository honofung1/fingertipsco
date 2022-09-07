class Admin < ApplicationRecord
  # Point this model to admin_users table
  self.table_name = "admin_users"

  #############################################################################
  # Constant
  #############################################################################

  # Defination of the role attribute of the admin
  # There is two roles in the admin model [admin, super_admin]
  # Different of the two roles
  # UPDATED AT: 2022/09/07
  # ------------------------------------------------------------------------
  # |    Function/Role  |         Admin        |        Super Admin        |
  # ------------------------------------------------------------------------
  # |  Access the order |                      |                           |
  # |  page             |           O          |              O            |
  # ------------------------------------------------------------------------
  # |  Access the admin |                      |                           |
  # |  page             |           x          |              O            |
  # ------------------------------------------------------------------------
  enum role: [:admin, :super_admin]

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

  validate :username_cannot_changed
  #############################################################################
  # Callback
  #############################################################################

  #############################################################################
  # Method
  #############################################################################

  def avatar_url
    # TODO: temp method
    # Path app/assets/images/avatar2.png
    "avatar1.png"
  end

  def admin_ability
    @admin_ability ||= AdminAbility.new(self)
  end

  delegate :can?, :cannot?, to: :admin_ability

  # From https://github.com/Sorcery/sorcery/blob/master/lib/sorcery/model/submodules/reset_password.rb
  # def change_password(new_password, raise_on_failure: false)
  #   send("password=", new_password)
  #   # send(:"#{sorcery_config.password_attribute_name}=", new_password)
  #   sorcery_adapter.save raise_on_failure: raise_on_failure
  # end

  #############################################################################
  # Private Method
  #############################################################################

  # if the record is persisted(already in db), not able to changed the username
  def username_cannot_changed
    if username_changed? && self.persisted?
      errors.add(:order_owner_id, "Changed on Username is not allowed!") # TODO: I18n
    end
  end
end
