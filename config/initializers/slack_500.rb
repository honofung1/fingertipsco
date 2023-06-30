require 'slack_500'

Slack500.setup do |config|
  # pretext
  config.pretext = 'FT Commerce(Production) occuring an error!!'

  # タイトル
  config.title = 'Exception.'

  # メッセージの左に表示されるバーのカラー
  config.color = '#FF0000'

  # フッターに表示する文字列
  config.footer = 'via Slack 500 Report.'

  # WebHook URL
  # see https://slack.com/services/new/incoming-webhook
  config.webhook_url = ENV['SLACK_HOOL_URL']
end
