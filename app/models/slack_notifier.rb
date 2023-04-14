class SlackNotifier
  attr_reader :client

  WEBHOOK_URL = "https://hooks.slack.com/services/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".freeze
  CHANNEL = "#ft-commerce-prod-noti".freeze
  USER_NAME = "Notifier".freeze

  def initialize
    @client = Slack::Notifier.new(WEBHOOK_URL, channel: CHANNEL, username: USER_NAME)
  end

  def send(title, message, color = '#36a64f')
    payload = {
      fallback: "UNEXPECTED ERROR",
      text: message,
      color: color
    }
    client.post text: title, attachments: [payload]
  end
end
