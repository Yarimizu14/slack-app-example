class AddBotTokenAndRemoveUserToken < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :slack_bot_token, :string
    remove_column :users, :access_token, :string
  end
end
