class CreateSlackJobNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :slack_job_notifications do |t|
      t.string :slack_channel_id
      t.string :slack_channel_name
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
