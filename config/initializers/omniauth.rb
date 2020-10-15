Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :slack, ENV['SLACK_OAUTH_CLIENT_ID'], ENV['SLACK_OAUTH_CLIENT_SECRET'], scope:'commands,chat:write,chat:write.customize'
  provider :slack, ENV['SLACK_OAUTH_CLIENT_ID'], ENV['SLACK_OAUTH_CLIENT_SECRET'], scope:'links:read,links:write,commands,chat:write,team:read'
end
