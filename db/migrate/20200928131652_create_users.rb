class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, :id => false do |t|
      t.string :id
      t.text :access_token

      t.timestamps
    end
    add_index :users, :id
  end
end
