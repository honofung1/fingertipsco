class Admin < ApplicationRecord
  self.table_name = "userdata"
  #############################################################################
  # Constant
  #############################################################################

  #############################################################################
  # Association
  #############################################################################

  #############################################################################
  # Validation
  #############################################################################

  #############################################################################
  # Callback
  #############################################################################

  #############################################################################
  # Method
  #############################################################################

  def avatar_url
    # Todo: temp method
    "app/assets/images/avatar2.png"
  end
  #############################################################################
  # Private Method
  #############################################################################
end
