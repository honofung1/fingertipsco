# frozen_string_literal: true

class Vendor::SessionsController < Devise::SessionsController
  layout 'vendor/layouts/admin_login'

  # before_action :configure_sign_in_params, only: [:create]
  skip_before_action :set_content_header

  # Skip cancan to avoid raising error
  skip_load_and_authorize_resource

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  protected

  def after_sign_in_path_for(resource)
    vendor_orders_path
  end

  def after_sign_out_path_for(resource_or_scope)
    # fallback to previous page
    request.referrer
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
