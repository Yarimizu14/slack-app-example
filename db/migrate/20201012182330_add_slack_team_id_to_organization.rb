class AddSlackTeamIdToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :slack_team_id, :string
  end
end
