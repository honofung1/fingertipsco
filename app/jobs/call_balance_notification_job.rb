class CallBalanceNotificationJob < ApplicationJob
  queue_as :default

  def perform
    OrderOwner.key_account.find_each do |owner|
      BalanceNotificationMailerJob.perform_later(owner) if owner.need_to_send_balance_notification?
    end
  end
end
