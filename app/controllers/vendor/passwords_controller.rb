# frozen_string_literal: true

class Vendor::PasswordsController < Devise::PasswordsController
  layout 'vendor/layouts/admin_login'

  # before_action :configure_sign_in_params, only: [:create]
  skip_before_action :set_content_header

  # Skip cancan to avoid raising error
  skip_load_and_authorize_resource

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  def after_resetting_password_path_for(resource)
    # super(resource)
    new_order_owner_account_session_path
  end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
