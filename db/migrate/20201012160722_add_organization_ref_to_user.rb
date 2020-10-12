class AddOrganizationRefToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :organization, foreign_key: true, null: false
  end
end
