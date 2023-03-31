# frozen_string_literal: true

class VendorMailer < Devise::Mailer
  def headers_for(action, opts)
    super.merge!({ template_path: 'vendor/mailer' })
  end
end
