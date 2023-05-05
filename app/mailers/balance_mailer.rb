class BalanceMailer < ApplicationMailer
  default from: 'system@fingertipsco.com'

  def balance_notification(order_owner)
    @order_owner = order_owner

    mail to: order_owner.email_account, subject: '[Fingertips] Account balance notification'
  end
end
