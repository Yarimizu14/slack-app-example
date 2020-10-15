class AddSlackIdToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :slack_id, :string
  end
end
