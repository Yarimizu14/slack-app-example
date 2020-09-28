class User < ApplicationRecord

  def self.find_or_create_from_auth_hash(slack_user)
    User.find_or_create_by(id: slack_user['id']) do |u|
      u.access_token = slack_user['access_token']
    end
  end
end
