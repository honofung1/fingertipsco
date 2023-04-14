class BalanceNotificationMailerJob < ApplicationJob
  queue_as :mailers

  after_perform do |job|
    if Rails.env.production?
      SlackNotifier.new.send("Balance notification mailer Job", "Sent balance notification email to #{job.arguments.first.name} Succesfully.")
    end
  end

  def perform(owner)
    if Rails.env.production?
      if owner.email_account.nil?
        SlackNotifier.new.send("[Exception] Balance notification mailer Job",
                               "Want to send email to KEY ACCOUNT [#{owner.name}] but the key aacount have not set the email yet.", 
                               "danger")
        return
      end
    end

    owner.send_balance_notification
  end
end
