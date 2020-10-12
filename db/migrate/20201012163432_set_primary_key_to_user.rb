class SetPrimaryKeyToUser < ActiveRecord::Migration[6.0]
  def up
    remove_column :users, :id
    add_column :users, :id, :primary_key
  end

  def down
    remove_column :users, :id
    add_column :users, :id, :string
  end
end
