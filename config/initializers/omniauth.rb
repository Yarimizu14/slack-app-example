Rails.application.config.middleware.use OmniAuth::Builder do
  provider :slack, ENV['SLACK_OAUTH_CLIENT_ID'], ENV['SLACK_OAUTH_CLIENT_SECRET'], scope:'commands,incoming-webhook', user_scope:'identity.basic'
end
