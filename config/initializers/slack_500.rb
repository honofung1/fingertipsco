require 'slack_500'

Slack500.setup do |config|
  # pretext
  config.pretext = 'Admin Panel occuring an error'

  # タイトル
  config.title = 'Rendering Exception.'

  # メッセージの左に表示されるバーのカラー
  config.color = '#FF0000'

  # フッターに表示する文字列
  config.footer = 'via Slack 500 Report.'

  # WebHook URL
  # see https://slack.com/services/new/incoming-webhook
  config.webhook_url = "https://hooks.slack.com/services/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"
end
